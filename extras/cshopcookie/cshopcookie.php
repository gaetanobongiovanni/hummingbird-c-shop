<?php
/**
 * C-Shop cookie consent.
 *
 * Banner + preferences for optional cookies (statistics, marketing), following
 * the Italian Garante guidelines of 10 June 2021: reject as easy as accept, the
 * X closes refusing, no cookie wall, the choice lasts 6 months and can be
 * changed from the footer. Sets Google Consent Mode v2 and releases scripts
 * written as <script type="text/plain" data-cs-consent="analytics|marketing">.
 *
 * Other modules can check the choice server side with Cshopcookie::hasConsent().
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

class Cshopcookie extends Module
{
    public const COOKIE = 'cshop_consent';
    public const CONFIG_VERSION = 'CSHOPCOOKIE_VERSION';
    public const CONFIG_ANALYTICS = 'CSHOPCOOKIE_ANALYTICS';
    public const CONFIG_MARKETING = 'CSHOPCOOKIE_MARKETING';
    public const CONFIG_POLICY_CMS = 'CSHOPCOOKIE_POLICY_CMS';

    public function __construct()
    {
        $this->name = 'cshopcookie';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'C-Teck';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->ps_versions_compliancy = ['min' => '9.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans('C-Shop cookie consent', [], 'Modules.Cshopcookie.Admin');
        $this->description = $this->trans(
            'Cookie banner and preferences with Google Consent Mode v2, following the Italian Garante guidelines.',
            [],
            'Modules.Cshopcookie.Admin'
        );
    }

    public function isUsingNewTranslationSystem(): bool
    {
        return true;
    }

    public function install(): bool
    {
        return parent::install()
            && Configuration::updateValue(self::CONFIG_VERSION, 1)
            && Configuration::updateValue(self::CONFIG_ANALYTICS, 1)
            && Configuration::updateValue(self::CONFIG_MARKETING, 1)
            && Configuration::updateValue(self::CONFIG_POLICY_CMS, $this->findCookiePolicyCms())
            && $this->registerHook([
                'displayHeader',
                'actionFrontControllerSetMedia',
                'displayBeforeBodyClosingTag',
                'displayFooterAfter',
            ]);
    }

    public function uninstall(): bool
    {
        foreach ([self::CONFIG_VERSION, self::CONFIG_ANALYTICS, self::CONFIG_MARKETING, self::CONFIG_POLICY_CMS] as $key) {
            Configuration::deleteByName($key);
        }

        return parent::uninstall();
    }

    /** CMS page whose friendly URL contains "cookie" (C-Shop: 7-cookie-policy) */
    private function findCookiePolicyCms(): int
    {
        return (int) Db::getInstance()->getValue(
            'SELECT id_cms FROM `' . _DB_PREFIX_ . 'cms_lang`
             WHERE link_rewrite LIKE \'%cookie%\' ORDER BY id_cms'
        );
    }

    /* ------------------------------------------------------------------ */
    /* Server-side helper                                                  */
    /* ------------------------------------------------------------------ */

    /**
     * True if the visitor allowed the category ("analytics" or "marketing")
     * for the current consent version.
     */
    public static function hasConsent(string $category): bool
    {
        $consent = self::parseCookie(
            $_COOKIE[self::COOKIE] ?? null,
            (int) Configuration::get(self::CONFIG_VERSION)
        );

        return $consent !== null && !empty($consent[$category]);
    }

    /** "<version>.<analytics>.<marketing>.<time>" -> array, or null if missing/old/invalid */
    public static function parseCookie(?string $value, int $version): ?array
    {
        if ($value === null || !preg_match('/^(\d+)\.([01])\.([01])\.(\d+)$/', $value, $m) || (int) $m[1] !== $version) {
            return null;
        }

        return ['analytics' => $m[2] === '1', 'marketing' => $m[3] === '1', 'time' => (int) $m[4]];
    }

    /* ------------------------------------------------------------------ */
    /* Hooks                                                               */
    /* ------------------------------------------------------------------ */

    private function isActiveBanner(): bool
    {
        return (bool) Configuration::get(self::CONFIG_ANALYTICS) || (bool) Configuration::get(self::CONFIG_MARKETING);
    }

    private function assignVars(): void
    {
        $cms = (int) Configuration::get(self::CONFIG_POLICY_CMS);
        $this->context->smarty->assign('cshopcookie', [
            'version' => (int) Configuration::get(self::CONFIG_VERSION),
            'analytics' => (bool) Configuration::get(self::CONFIG_ANALYTICS),
            'marketing' => (bool) Configuration::get(self::CONFIG_MARKETING),
            'policy_url' => $cms ? $this->context->link->getCMSLink($cms) : '',
        ]);
    }

    /** Consent Mode defaults: must come before any Google tag in <head> */
    public function hookDisplayHeader(): string
    {
        $this->assignVars();

        return $this->fetch('module:cshopcookie/views/templates/hook/head.tpl');
    }

    public function hookActionFrontControllerSetMedia(): void
    {
        if (!$this->isActiveBanner()) {
            return;
        }
        $this->context->controller->registerStylesheet(
            'cshopcookie-css',
            'modules/' . $this->name . '/views/css/cookie.css',
            ['media' => 'all', 'priority' => 200]
        );
        $this->context->controller->registerJavascript(
            'cshopcookie-js',
            'modules/' . $this->name . '/views/js/cookie.js',
            ['position' => 'bottom', 'priority' => 50]
        );
    }

    public function hookDisplayBeforeBodyClosingTag(): string
    {
        if (!$this->isActiveBanner()) {
            return '';
        }
        $this->assignVars();

        return $this->fetch('module:cshopcookie/views/templates/hook/banner.tpl');
    }

    public function hookDisplayFooterAfter(): string
    {
        if (!$this->isActiveBanner()) {
            return '';
        }

        return $this->fetch('module:cshopcookie/views/templates/hook/footer-link.tpl');
    }

    /* ------------------------------------------------------------------ */
    /* Configuration                                                       */
    /* ------------------------------------------------------------------ */

    public function getContent(): string
    {
        $output = '';
        if (Tools::isSubmit('submitCshopcookie')) {
            Configuration::updateValue(self::CONFIG_ANALYTICS, (int) (bool) Tools::getValue(self::CONFIG_ANALYTICS));
            Configuration::updateValue(self::CONFIG_MARKETING, (int) (bool) Tools::getValue(self::CONFIG_MARKETING));
            Configuration::updateValue(self::CONFIG_POLICY_CMS, (int) Tools::getValue(self::CONFIG_POLICY_CMS));
            $output .= $this->displayConfirmation($this->trans('Settings saved.', [], 'Modules.Cshopcookie.Admin'));
        }
        if (Tools::isSubmit('submitCshopcookieRenew')) {
            Configuration::updateValue(self::CONFIG_VERSION, (int) Configuration::get(self::CONFIG_VERSION) + 1);
            $output .= $this->displayConfirmation($this->trans(
                'Consent renewed: every visitor will see the banner again.',
                [],
                'Modules.Cshopcookie.Admin'
            ));
        }

        $pages = [['id' => 0, 'name' => '-']];
        foreach (CMS::getCMSPages((int) $this->context->language->id, null, false) as $page) {
            $pages[] = ['id' => (int) $page['id_cms'], 'name' => $page['meta_title']];
        }
        $yesNo = [
            ['id' => 'on', 'value' => 1, 'label' => $this->trans('Yes', [], 'Admin.Global')],
            ['id' => 'off', 'value' => 0, 'label' => $this->trans('No', [], 'Admin.Global')],
        ];

        $helper = new HelperForm();
        $helper->module = $this;
        $helper->name_controller = $this->name;
        $helper->token = Tools::getAdminTokenLite('AdminModules');
        $helper->currentIndex = AdminController::$currentIndex . '&configure=' . $this->name;
        $helper->default_form_language = (int) $this->context->language->id;
        $helper->fields_value = [
            self::CONFIG_ANALYTICS => (int) Configuration::get(self::CONFIG_ANALYTICS),
            self::CONFIG_MARKETING => (int) Configuration::get(self::CONFIG_MARKETING),
            self::CONFIG_POLICY_CMS => (int) Configuration::get(self::CONFIG_POLICY_CMS),
        ];

        $settings = [
            'form' => [
                'legend' => ['title' => $this->trans('Cookie banner', [], 'Modules.Cshopcookie.Admin'), 'icon' => 'icon-cogs'],
                'description' => $this->trans(
                    'Turn on only the categories the shop really uses. With both off the banner is hidden: technical cookies need no consent.',
                    [],
                    'Modules.Cshopcookie.Admin'
                ),
                'input' => [
                    [
                        'type' => 'switch',
                        'name' => self::CONFIG_ANALYTICS,
                        'label' => $this->trans('Statistics cookies (e.g. Google Analytics)', [], 'Modules.Cshopcookie.Admin'),
                        'values' => $yesNo,
                    ],
                    [
                        'type' => 'switch',
                        'name' => self::CONFIG_MARKETING,
                        'label' => $this->trans('Marketing cookies (e.g. Meta Pixel, Google Ads)', [], 'Modules.Cshopcookie.Admin'),
                        'values' => $yesNo,
                    ],
                    [
                        'type' => 'select',
                        'name' => self::CONFIG_POLICY_CMS,
                        'label' => $this->trans('Cookie policy page', [], 'Modules.Cshopcookie.Admin'),
                        'options' => ['query' => $pages, 'id' => 'id', 'name' => 'name'],
                    ],
                ],
                'submit' => ['title' => $this->trans('Save', [], 'Admin.Actions'), 'name' => 'submitCshopcookie'],
            ],
        ];
        $renew = [
            'form' => [
                'legend' => ['title' => $this->trans('Ask for consent again', [], 'Modules.Cshopcookie.Admin'), 'icon' => 'icon-refresh'],
                'description' => $this->trans(
                    'Use it when you add a new service or change the cookie policy: the choices already given stop being valid (current version: %version%).',
                    ['%version%' => (int) Configuration::get(self::CONFIG_VERSION)],
                    'Modules.Cshopcookie.Admin'
                ),
                'submit' => ['title' => $this->trans('Ask everybody again', [], 'Modules.Cshopcookie.Admin'), 'name' => 'submitCshopcookieRenew'],
            ],
        ];

        return $output . $helper->generateForm([$settings, $renew]);
    }
}
