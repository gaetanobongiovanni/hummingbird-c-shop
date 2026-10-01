<?php
/**
 * C-Shop B2B registration.
 *
 * Adds to the registration form the customer type (private, company buying for
 * its own use, reseller, public body), the legal form (sole trader / company)
 * and the Italian e-invoicing data. Resellers must upload their visura camerale:
 * they can shop at list price at once and get the "Rivenditori" group (reseller
 * prices) only after the shop approves the document in the back office.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once __DIR__ . '/classes/CshopB2bValidator.php';
require_once __DIR__ . '/classes/CshopB2bRepository.php';

class Cshopb2b extends Module
{
    public const CONFIG_NOTIFY = 'CSHOPB2B_NOTIFY_EMAIL';

    /** Pages where the B2B fields are added (account creation only) */
    private const REGISTRATION_PAGES = ['registration', 'authentication'];

    public $tabs = [
        [
            'name' => 'Richieste B2B',
            'class_name' => 'AdminCshopB2b',
            'visible' => true,
            'parent_class_name' => 'AdminParentCustomer',
        ],
    ];

    public function __construct()
    {
        $this->name = 'cshopb2b';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'C-Teck';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->ps_versions_compliancy = ['min' => '9.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans('C-Shop B2B registration', [], 'Modules.Cshopb2b.Admin');
        $this->description = $this->trans(
            'Customer type, Italian e-invoicing data and reseller approval with visura upload.',
            [],
            'Modules.Cshopb2b.Admin'
        );
    }

    public function isUsingNewTranslationSystem(): bool
    {
        return true;
    }

    public function install(): bool
    {
        return parent::install()
            && CshopB2bRepository::installSchema()
            && CshopB2bRepository::installGroups()
            && Configuration::updateValue(self::CONFIG_NOTIFY, 'buyer@c-commerce.it')
            && $this->registerHook([
                'additionalCustomerFormFields',
                'validateCustomerFormFields',
                'actionCustomerAccountAdd',
                'displayAdminCustomers',
                'displayCustomerAccount',
            ]);
    }

    /**
     * Data and groups are kept on uninstall on purpose: customers stay in their
     * groups and the visure stay available if the module is reinstalled.
     */
    public function uninstall(): bool
    {
        return parent::uninstall();
    }

    // ---------------------------------------------------------------------
    // Configuration page
    // ---------------------------------------------------------------------

    public function getContent(): string
    {
        $output = '';
        if (Tools::isSubmit('submitCshopb2b')) {
            $email = trim((string) Tools::getValue(self::CONFIG_NOTIFY));
            if ($email !== '' && !Validate::isEmail($email)) {
                $output .= $this->displayError($this->trans('Invalid email address.', [], 'Modules.Cshopb2b.Admin'));
            } else {
                Configuration::updateValue(self::CONFIG_NOTIFY, $email);
                $output .= $this->displayConfirmation($this->trans('Settings updated.', [], 'Modules.Cshopb2b.Admin'));
            }
        }

        $helper = new HelperForm();
        $helper->module = $this;
        $helper->name_controller = $this->name;
        $helper->token = Tools::getAdminTokenLite('AdminModules');
        $helper->currentIndex = AdminController::$currentIndex . '&configure=' . $this->name;
        $helper->submit_action = 'submitCshopb2b';
        $helper->default_form_language = (int) $this->context->language->id;
        $helper->fields_value = [self::CONFIG_NOTIFY => Configuration::get(self::CONFIG_NOTIFY)];

        $groups = [];
        foreach (CshopB2bRepository::GROUP_NAMES as $key => $name) {
            $groups[] = $name . ' (ID ' . CshopB2bRepository::groupId($key) . ')';
        }

        $form = [
            'form' => [
                'legend' => ['title' => $this->displayName, 'icon' => 'icon-briefcase'],
                'description' => $this->trans(
                    'Customer groups created by the module: %groups%. Set discounts and price display in Customers > Groups. Pending reseller requests: Customers > B2B requests.',
                    ['%groups%' => implode(', ', $groups)],
                    'Modules.Cshopb2b.Admin'
                ),
                'input' => [
                    [
                        'type' => 'text',
                        'name' => self::CONFIG_NOTIFY,
                        'label' => $this->trans('Notify new reseller requests to', [], 'Modules.Cshopb2b.Admin'),
                        'desc' => $this->trans('Leave empty to disable the email.', [], 'Modules.Cshopb2b.Admin'),
                    ],
                ],
                'submit' => ['title' => $this->trans('Save', [], 'Admin.Actions')],
            ],
        ];

        return $output . $helper->generateForm([$form]);
    }

    // ---------------------------------------------------------------------
    // Front office: registration form
    // ---------------------------------------------------------------------

    private function isRegistrationPage(): bool
    {
        $controller = $this->context->controller;

        return $controller instanceof FrontController
            && in_array($controller->php_self ?? '', self::REGISTRATION_PAGES, true);
    }

    private function shopTrans(string $text, array $params = []): string
    {
        return $this->trans($text, $params, 'Modules.Cshopb2b.Shop');
    }

    /**
     * The conditional fields are not "required" for the core (privates do not
     * fill them): the module validates them, the theme shows/hides them from
     * the data-ps-b2b-* attributes.
     */
    public function hookAdditionalCustomerFormFields(array $params): array
    {
        if (!$this->isRegistrationPage()) {
            return [];
        }

        $business = 'azienda rivenditore';
        $all = 'azienda rivenditore ente';

        $field = static function (string $name, string $type, string $label, string $show, string $required): FormField {
            return (new FormField())
                ->setName($name)
                ->setType($type)
                ->setLabel($label)
                ->setAttr(['data-ps-b2b-show' => $show, 'data-ps-b2b-required' => $required]);
        };

        $type = (new FormField())
            ->setName('cs_customer_type')
            ->setType('radio-buttons')
            ->setLabel($this->shopTrans('I am registering as'))
            ->setRequired(true)
            ->setValue(CshopB2bValidator::TYPE_PRIVATE)
            ->setAvailableValues([
                CshopB2bValidator::TYPE_PRIVATE => $this->shopTrans('Private customer'),
                CshopB2bValidator::TYPE_COMPANY => $this->shopTrans('Company (own use)'),
                CshopB2bValidator::TYPE_RESELLER => $this->shopTrans('Reseller'),
                CshopB2bValidator::TYPE_PUBLIC => $this->shopTrans('Public body'),
            ])
            ->setAttr(['data-ps-b2b-show' => 'always', 'data-ps-b2b-required' => 'always']);

        $legalForm = $field('cs_legal_form', 'radio-buttons', $this->shopTrans('Legal form'), $business, $business)
            ->setAvailableValues([
                CshopB2bValidator::FORM_SOLE => $this->shopTrans('Sole trader'),
                CshopB2bValidator::FORM_COMPANY => $this->shopTrans('Company (srl, spa, snc, sas…)'),
            ]);

        $company = $field('cs_company', 'text', $this->shopTrans('Company name / name of the body'), $all, $all)
            ->setMaxLength(255)
            ->setAutocompleteAttribute('organization');

        $vat = $field('cs_vat', 'text', $this->shopTrans('VAT number'), $all, $business)
            ->setMaxLength(13)
            ->setAvailableValues(['placeholder' => '01234567890']);

        $taxCode = $field('cs_tax_code', 'text', $this->shopTrans('Tax code'), $all, $all)
            ->setMaxLength(16)
            ->setAvailableValues([
                'comment' => $this->shopTrans('Sole trader: the owner\'s personal tax code. Company or public body: the 11-digit tax code.'),
            ]);

        $sdi = $field('cs_sdi', 'text', $this->shopTrans('SDI recipient code'), $business, '')
            ->setMaxLength(7)
            ->setAvailableValues([
                'placeholder' => 'ABC1234',
                'comment' => $this->shopTrans('7 characters, for electronic invoices. Not available? Enter your PEC address.'),
            ]);

        $ipa = $field('cs_ipa', 'text', $this->shopTrans('Office unique code (IPA)'), 'ente', 'ente')
            ->setMaxLength(6)
            ->setAvailableValues(['placeholder' => 'UFABCD']);

        $pec = $field('cs_pec', 'email', $this->shopTrans('PEC address'), $all, '')
            ->setMaxLength(255);

        $visura = $field('cs_visura', 'file', $this->shopTrans('Chamber of commerce extract (visura camerale)'), 'rivenditore', 'rivenditore')
            ->setAttr([
                'data-ps-b2b-show' => 'rivenditore',
                'data-ps-b2b-required' => 'rivenditore',
                'accept' => '.pdf,.jpg,.jpeg,.png,application/pdf,image/jpeg,image/png',
            ])
            ->setAvailableValues([
                'comment' => $this->shopTrans('PDF, JPG or PNG, max 5 MB, issued in the last 6 months. Reseller prices are activated after we check it.'),
            ]);

        return [$type, $legalForm, $company, $vat, $taxCode, $sdi, $ipa, $pec, $visura];
    }

    /**
     * @param array{fields: FormField[]} $params
     */
    public function hookValidateCustomerFormFields(array $params): array
    {
        /** @var FormField[] $fields */
        $fields = [];
        foreach ($params['fields'] as $field) {
            $fields[$field->getName()] = $field;
        }
        if (!isset($fields['cs_customer_type'])) {
            return $params['fields'];
        }

        $data = $this->postedData();
        $errors = CshopB2bValidator::validate($data);

        if ($data['type'] === CshopB2bValidator::TYPE_RESELLER) {
            $visuraError = CshopB2bValidator::validateVisura($_FILES['cs_visura'] ?? null);
            if ($visuraError !== '') {
                $errors['cs_visura'] = $visuraError;
            }
        }

        foreach ($errors as $name => $code) {
            if (isset($fields[$name])) {
                $fields[$name]->addError($this->errorMessage($code));
            }
        }

        return $params['fields'];
    }

    private function errorMessage(string $code): string
    {
        switch ($code) {
            case 'type':
                return $this->shopTrans('Choose how you are registering.');
            case 'vat':
                return $this->shopTrans('The VAT number is not valid (11 digits).');
            case 'tax_code_person':
                return $this->shopTrans('For a sole trader enter the owner\'s personal tax code (16 characters).');
            case 'tax_code_company':
                return $this->shopTrans('Enter the 11-digit tax code.');
            case 'sdi':
                return $this->shopTrans('The SDI recipient code has 7 characters.');
            case 'sdi_or_pec':
                return $this->shopTrans('Enter the SDI recipient code or a PEC address for electronic invoices.');
            case 'ipa':
                return $this->shopTrans('The office unique code has 6 characters.');
            case 'pec':
                return $this->shopTrans('The PEC address is not valid.');
            case 'visura_required':
                return $this->shopTrans('Resellers must upload the chamber of commerce extract.');
            case 'visura_size':
                return $this->shopTrans('The file is too large (max 5 MB).');
            case 'visura_type':
                return $this->shopTrans('Upload a PDF, JPG or PNG file.');
            case 'visura_upload':
                return $this->shopTrans('The file could not be uploaded, please try again.');
            default:
                return $this->shopTrans('Required field');
        }
    }

    /** @return array<string, string> */
    private function postedData(): array
    {
        $get = static fn (string $name): string => trim((string) Tools::getValue($name, ''));

        return [
            'type' => $get('cs_customer_type') ?: CshopB2bValidator::TYPE_PRIVATE,
            'legal_form' => $get('cs_legal_form'),
            'company' => $get('cs_company'),
            'vat' => $get('cs_vat'),
            'tax_code' => $get('cs_tax_code'),
            'sdi' => $get('cs_sdi'),
            'ipa' => $get('cs_ipa'),
            'pec' => $get('cs_pec'),
        ];
    }

    /**
     * @param array{newCustomer: Customer} $params
     */
    public function hookActionCustomerAccountAdd(array $params): void
    {
        $customer = $params['newCustomer'] ?? null;
        if (!$customer instanceof Customer || !Validate::isLoadedObject($customer) || Tools::getValue('cs_customer_type') === false) {
            return;
        }

        $data = $this->postedData();
        if ($data['type'] === CshopB2bValidator::TYPE_PRIVATE || CshopB2bValidator::validate($data) !== []) {
            return;
        }

        $isPublic = $data['type'] === CshopB2bValidator::TYPE_PUBLIC;
        $row = [
            'customer_type' => $data['type'],
            'legal_form' => $isPublic ? '' : $data['legal_form'],
            'company' => $data['company'],
            'vat_number' => CshopB2bValidator::normalize($data['vat']),
            'tax_code' => CshopB2bValidator::normalize($data['tax_code']),
            'sdi_code' => $isPublic ? '' : CshopB2bValidator::normalize($data['sdi']),
            'ipa_code' => $isPublic ? CshopB2bValidator::normalize($data['ipa']) : '',
            'pec' => $data['pec'],
            'status' => CshopB2bRepository::STATUS_NONE,
        ];

        $stored = null;
        if ($data['type'] === CshopB2bValidator::TYPE_RESELLER) {
            $row['status'] = CshopB2bRepository::STATUS_PENDING;
            if (isset($_FILES['cs_visura']) && CshopB2bValidator::validateVisura($_FILES['cs_visura']) === '') {
                $stored = CshopB2bRepository::storeVisura($_FILES['cs_visura']);
                if ($stored) {
                    $row['visura_file'] = $stored['file'];
                    $row['visura_name'] = $stored['name'];
                    $row['visura_mime'] = $stored['mime'];
                }
            }
        }

        CshopB2bRepository::save((int) $customer->id, $row);

        // company name on the customer record (back office lists, B2B fields)
        if (Validate::isGenericName($data['company'])) {
            $customer->company = $data['company'];
        }

        $groupKey = [
            CshopB2bValidator::TYPE_COMPANY => 'company',
            CshopB2bValidator::TYPE_RESELLER => 'reseller_pending',
            CshopB2bValidator::TYPE_PUBLIC => 'public',
        ][$data['type']];
        CshopB2bRepository::assignGroup($customer, $groupKey);

        if ($data['type'] === CshopB2bValidator::TYPE_RESELLER) {
            $this->notifyNewReseller($customer, $row);
            $this->mailCustomer($customer, 'cshopb2b_received', $this->customerSubject($customer, 'We received your reseller request'));
        }
    }

    // ---------------------------------------------------------------------
    // Emails
    // ---------------------------------------------------------------------

    private function notifyNewReseller(Customer $customer, array $row): void
    {
        $to = (string) Configuration::get(self::CONFIG_NOTIFY);
        if ($to === '' || !Validate::isEmail($to)) {
            return;
        }

        $attachment = null;
        $path = CshopB2bRepository::visuraPath($row);
        if ($path && filesize($path) <= CshopB2bValidator::VISURA_MAX_BYTES) {
            $attachment = ['content' => file_get_contents($path), 'name' => $row['visura_name'], 'mime' => $row['visura_mime']];
        }

        // values typed by the registrant: escaped, Mail::send does not escape template vars
        $e = static fn ($value): string => htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');

        Mail::send(
            (int) Configuration::get('PS_LANG_DEFAULT'),
            'cshopb2b_new_reseller',
            $this->trans('New reseller to approve: %company%', ['%company%' => $row['company']], 'Modules.Cshopb2b.Admin'),
            [
                '{company}' => $e($row['company']),
                '{firstname}' => $e($customer->firstname),
                '{lastname}' => $e($customer->lastname),
                '{email}' => $e($customer->email),
                '{vat}' => $e($row['vat_number']),
                '{tax_code}' => $e($row['tax_code']),
                '{legal_form}' => $row['legal_form'] === CshopB2bValidator::FORM_SOLE ? 'Ditta individuale' : 'Società',
                '{visura}' => $path ? $e($row['visura_name']) : 'NON CARICATA',
            ],
            $to,
            null,
            null,
            null,
            $attachment,
            null,
            $this->getLocalPath() . 'mails/'
        );
    }

    /** Email subject in the customer's language (not the employee's back office language). */
    public function customerSubject(Customer $customer, string $text): string
    {
        return $this->trans($text, [], 'Modules.Cshopb2b.Admin', Language::getLocaleById((int) $customer->id_lang) ?: null);
    }

    public function mailCustomer(Customer $customer, string $template, string $subject, array $vars = []): void
    {
        Mail::send(
            (int) $customer->id_lang,
            $template,
            $subject,
            $vars + [
                '{firstname}' => htmlspecialchars($customer->firstname, ENT_QUOTES, 'UTF-8'),
                '{lastname}' => htmlspecialchars($customer->lastname, ENT_QUOTES, 'UTF-8'),
                '{shop_url}' => $this->context->link->getPageLink('index', true),
            ],
            $customer->email,
            $customer->firstname . ' ' . $customer->lastname,
            null,
            null,
            null,
            null,
            $this->getLocalPath() . 'mails/'
        );
    }

    // ---------------------------------------------------------------------
    // Back office: customer page panel, front office: account status
    // ---------------------------------------------------------------------

    public function hookDisplayAdminCustomers(array $params): string
    {
        $idCustomer = (int) ($params['id_customer'] ?? 0);
        $row = $idCustomer ? CshopB2bRepository::get($idCustomer) : null;
        if (!$row) {
            return '';
        }

        $this->context->smarty->assign([
            'cs_b2b' => $row,
            'cs_has_visura' => CshopB2bRepository::visuraPath($row) !== null,
            'cs_link' => $this->context->link->getAdminLink('AdminCshopB2b', true, [], ['id_customer' => $idCustomer]),
        ]);

        return $this->display(__FILE__, 'views/templates/admin/customer_panel.tpl');
    }

    public function hookDisplayCustomerAccount(): string
    {
        $row = CshopB2bRepository::get((int) $this->context->customer->id);
        if (!$row || $row['customer_type'] === CshopB2bValidator::TYPE_PRIVATE) {
            return '';
        }

        $this->context->smarty->assign(['cs_b2b' => $row]);

        return $this->display(__FILE__, 'views/templates/hook/my-account.tpl');
    }
}
