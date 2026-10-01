<?php
/**
 * C-Shop B2B — back office: business customers, reseller approval, visura download.
 * Customers > B2B requests.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'cshopb2b/classes/CshopB2bValidator.php';
require_once _PS_MODULE_DIR_ . 'cshopb2b/classes/CshopB2bRepository.php';

class AdminCshopB2bController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        parent::__construct();
    }

    private function t(string $text, array $params = []): string
    {
        return $this->trans($text, $params, 'Modules.Cshopb2b.Admin');
    }

    public function postProcess()
    {
        $idCustomer = (int) Tools::getValue('id_customer');

        if (!$this->viewAccess()) {
            return parent::postProcess();
        }

        if (Tools::getValue('action') === 'download' && $idCustomer) {
            $this->downloadVisura($idCustomer);
        }

        if (Tools::isSubmit('cshopb2b_action') && $idCustomer && !$this->access('edit')) {
            $this->errors[] = $this->trans('You do not have permission to edit this.', [], 'Admin.Notifications.Error');
        } elseif (Tools::isSubmit('cshopb2b_action') && $idCustomer) {
            $row = CshopB2bRepository::get($idCustomer);
            $customer = new Customer($idCustomer);
            if (!$row || !Validate::isLoadedObject($customer) || $row['customer_type'] !== CshopB2bValidator::TYPE_RESELLER) {
                $this->errors[] = $this->t('Request not found.');

                return parent::postProcess();
            }

            $note = trim((string) Tools::getValue('cshopb2b_note'));
            $action = (string) Tools::getValue('cshopb2b_action');

            if ($action === 'approve') {
                CshopB2bRepository::assignGroup($customer, 'reseller');
                CshopB2bRepository::setStatus($idCustomer, CshopB2bRepository::STATUS_APPROVED, $note);
                $this->module->mailCustomer($customer, 'cshopb2b_approved', $this->module->customerSubject($customer, 'Your reseller account is active'));
                $this->confirmations[] = $this->t('Reseller approved: reseller prices are now active for %company%.', ['%company%' => $row['company']]);
            } elseif ($action === 'reject') {
                // still a business customer: moved to the companies group, list prices
                CshopB2bRepository::assignGroup($customer, 'company');
                CshopB2bRepository::setStatus($idCustomer, CshopB2bRepository::STATUS_REJECTED, $note);
                $this->module->mailCustomer($customer, 'cshopb2b_rejected', $this->module->customerSubject($customer, 'About your reseller request'), [
                    '{note}' => $note !== '' ? nl2br(htmlspecialchars($note, ENT_QUOTES, 'UTF-8')) : '-',
                ]);
                $this->confirmations[] = $this->t('Request rejected: the customer stays in the Companies group.');
            }
        }

        return parent::postProcess();
    }

    private function downloadVisura(int $idCustomer): void
    {
        $row = CshopB2bRepository::get($idCustomer);
        $path = $row ? CshopB2bRepository::visuraPath($row) : null;
        if (!$path) {
            $this->errors[] = $this->t('The file is not available.');

            return;
        }

        $mime = isset(CshopB2bValidator::VISURA_MIME[$row['visura_mime']]) ? $row['visura_mime'] : 'application/octet-stream';
        $name = 'visura-' . preg_replace('/[^A-Za-z0-9]+/', '-', $row['company']) . '.' . (CshopB2bValidator::VISURA_MIME[$mime] ?? 'bin');

        while (ob_get_level() > 0) {
            ob_end_clean();
        }
        header('Content-Type: ' . $mime);
        header('Content-Length: ' . filesize($path));
        header('Content-Disposition: inline; filename="' . $name . '"');
        header('X-Content-Type-Options: nosniff');
        header('Cache-Control: private, no-store');
        readfile($path);
        exit;
    }

    public function initContent()
    {
        parent::initContent();
        if (!$this->viewAccess()) {
            return;
        }

        $idCustomer = (int) Tools::getValue('id_customer');
        $filter = (string) Tools::getValue('status', CshopB2bRepository::STATUS_PENDING);
        $statuses = [
            CshopB2bRepository::STATUS_PENDING => $this->t('Resellers to approve'),
            CshopB2bRepository::STATUS_APPROVED => $this->t('Approved resellers'),
            CshopB2bRepository::STATUS_REJECTED => $this->t('Rejected'),
            'all' => $this->t('All business customers'),
        ];
        if (!isset($statuses[$filter])) {
            $filter = CshopB2bRepository::STATUS_PENDING;
        }

        $self = $this->context->link->getAdminLink('AdminCshopB2b');
        $vars = [
            'cs_self' => $self,
            'cs_statuses' => $statuses,
            'cs_filter' => $filter,
            'cs_types' => $this->typeLabels(),
            'cs_forms' => [
                CshopB2bValidator::FORM_SOLE => $this->t('Sole trader'),
                CshopB2bValidator::FORM_COMPANY => $this->t('Company'),
            ],
            'cs_status_labels' => [
                CshopB2bRepository::STATUS_NONE => '-',
                CshopB2bRepository::STATUS_PENDING => $this->t('To approve'),
                CshopB2bRepository::STATUS_APPROVED => $this->t('Approved'),
                CshopB2bRepository::STATUS_REJECTED => $this->t('Rejected'),
            ],
        ];

        if ($idCustomer && ($row = CshopB2bRepository::get($idCustomer))) {
            $customer = new Customer($idCustomer);
            $vars += [
                'cs_row' => $row,
                'cs_customer' => $customer,
                'cs_has_visura' => CshopB2bRepository::visuraPath($row) !== null,
                'cs_customer_link' => $this->context->link->getAdminLink('AdminCustomers', true, ['route' => 'admin_customers_view', 'customerId' => $idCustomer]),
            ];
            $template = 'detail.tpl';
        } else {
            $vars['cs_rows'] = $this->listRows($filter);
            $template = 'list.tpl';
        }

        $this->context->smarty->assign($vars);
        $this->content .= $this->context->smarty->fetch($this->module->getLocalPath() . 'views/templates/admin/' . $template);
        $this->context->smarty->assign('content', $this->content);
    }

    private function typeLabels(): array
    {
        return [
            CshopB2bValidator::TYPE_COMPANY => $this->t('Company'),
            CshopB2bValidator::TYPE_RESELLER => $this->t('Reseller'),
            CshopB2bValidator::TYPE_PUBLIC => $this->t('Public body'),
        ];
    }

    private function listRows(string $filter): array
    {
        $where = $filter === 'all' ? '1' : 'b.`status` = \'' . pSQL($filter) . '\'';

        return Db::getInstance()->executeS(
            'SELECT b.*, c.`firstname`, c.`lastname`, c.`email`
            FROM `' . _DB_PREFIX_ . CshopB2bRepository::TABLE . '` b
            INNER JOIN `' . _DB_PREFIX_ . 'customer` c ON c.`id_customer` = b.`id_customer`
            WHERE ' . $where . '
            ORDER BY b.`date_add` DESC
            LIMIT 500'
        ) ?: [];
    }
}
