<?php
/**
 * C-Shop cash on delivery with surcharge.
 *
 * Replaces ps_cashondelivery: same payment flow, plus a surcharge of a fixed
 * amount + a percentage of the order total (shipping and VAT included). The
 * surcharge is added to the order as a hidden virtual product ("Spese
 * contrassegno"), so it shows as its own line in the order, the invoice and the
 * confirmation email, with VAT computed by PrestaShop.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once __DIR__ . '/classes/CshopCodFee.php';

use PrestaShop\PrestaShop\Core\Payment\PaymentOption;

class Cshopcod extends PaymentModule
{
    public const CONFIG_FIXED = 'CSHOPCOD_FEE_FIXED';
    public const CONFIG_PERCENT = 'CSHOPCOD_FEE_PERCENT';
    public const CONFIG_PRODUCT = 'CSHOPCOD_FEE_PRODUCT';
    public const FEE_REFERENCE = 'CSHOPCOD-FEE';
    /** Stock kept on the surcharge product so orders never become "on backorder" */
    private const FEE_STOCK = 1000000;

    /**
     * True while the module itself adds the surcharge and creates the order, so
     * actionCartSave (fired by Cart::update inside validateOrder too) leaves it in.
     */
    private static $addingFee = false;

    public static function allowFeeInCart(bool $allow): void
    {
        self::$addingFee = $allow;
    }

    public function __construct()
    {
        $this->name = 'cshopcod';
        $this->tab = 'payments_gateways';
        $this->version = '1.0.1';
        $this->author = 'C-Teck';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->currencies = true;
        $this->currencies_mode = 'checkbox';
        $this->ps_versions_compliancy = ['min' => '9.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans('C-Shop cash on delivery with surcharge', [], 'Modules.Cshopcod.Admin');
        $this->description = $this->trans(
            'Cash on delivery with a fixed + percentage surcharge added to the order as its own line.',
            [],
            'Modules.Cshopcod.Admin'
        );
    }

    public function isUsingNewTranslationSystem(): bool
    {
        return true;
    }

    public function install(): bool
    {
        return parent::install()
            && Configuration::updateValue(self::CONFIG_FIXED, '2.50')
            && Configuration::updateValue(self::CONFIG_PERCENT, '1.4')
            // SpecificPrice::isFeatureActive() is cached per request: a shop with no
            // specific prices yet would price the surcharge at 0 in the first order
            && Configuration::updateGlobalValue('PS_SPECIFIC_PRICE_FEATURE_ACTIVE', 1)
            && $this->installFeeProduct()
            && $this->registerHook(['paymentOptions', 'displayPaymentReturn', 'actionCartSave']);
    }

    /**
     * The surcharge product is kept on uninstall: past orders reference it.
     * It stays hidden (visibility none) and can be deleted by hand if wanted.
     */
    public function uninstall(): bool
    {
        Configuration::deleteByName(self::CONFIG_FIXED);
        Configuration::deleteByName(self::CONFIG_PERCENT);

        return parent::uninstall();
    }

    /* ------------------------------------------------------------------ */
    /* Surcharge product                                                   */
    /* ------------------------------------------------------------------ */

    private function installFeeProduct(): bool
    {
        $existing = (int) Product::getIdByReference(self::FEE_REFERENCE);
        if ($existing) {
            $this->ensureFeeStock($existing);

            return Configuration::updateValue(self::CONFIG_PRODUCT, $existing);
        }

        $product = new Product();
        foreach (Language::getLanguages(false) as $lang) {
            $product->name[$lang['id_lang']] = 'Spese contrassegno';
            $product->link_rewrite[$lang['id_lang']] = 'spese-contrassegno';
        }
        $product->reference = self::FEE_REFERENCE;
        $product->price = 0;
        $product->id_tax_rules_group = $this->mostUsedTaxRulesGroup();
        $product->is_virtual = true;
        if (property_exists($product, 'product_type')) {
            $product->product_type = 'virtual';
        }
        $product->visibility = 'none';
        $product->indexed = 0;
        $product->active = true;
        $product->available_for_order = true;
        $product->show_price = true;
        $product->id_category_default = (int) Configuration::get('PS_HOME_CATEGORY');
        if (!$product->add()) {
            return false;
        }
        $product->addToCategories([(int) Configuration::get('PS_HOME_CATEGORY')]);
        StockAvailable::setProductOutOfStock((int) $product->id, 1);
        $this->ensureFeeStock((int) $product->id);

        return Configuration::updateValue(self::CONFIG_PRODUCT, (int) $product->id);
    }

    /** Tax rules of the catalogue (IVA 22% on C-Shop): the group most products use. */
    private function mostUsedTaxRulesGroup(): int
    {
        return (int) Db::getInstance()->getValue(
            'SELECT id_tax_rules_group FROM `' . _DB_PREFIX_ . 'product`
             WHERE id_tax_rules_group > 0
             GROUP BY id_tax_rules_group ORDER BY COUNT(*) DESC'
        );
    }

    /**
     * A product with stock <= 0 in an order switches it to "on backorder" and can
     * split it into a second order: keep the surcharge always in stock.
     */
    private function ensureFeeStock(int $idProduct): void
    {
        if ((int) StockAvailable::getQuantityAvailableByProduct($idProduct) < 1000) {
            StockAvailable::setQuantity($idProduct, 0, self::FEE_STOCK);
        }
    }

    /** Cart::containsProduct() no longer exists in PrestaShop 9: query cart_product directly */
    public function cartHasFee(Cart $cart): bool
    {
        $idProduct = $this->feeProductId();
        if (!$idProduct || !$cart->id) {
            return false;
        }

        return (bool) Db::getInstance()->getValue(
            'SELECT 1 FROM `' . _DB_PREFIX_ . 'cart_product`
             WHERE id_cart = ' . (int) $cart->id . ' AND id_product = ' . (int) $idProduct
        );
    }

    /** Cart::orderExists() is not guaranteed in PrestaShop 9 either */
    public static function cartIsOrdered(Cart $cart): bool
    {
        return $cart->id && (int) Order::getIdByCartId((int) $cart->id) > 0;
    }

    private function feeProductId(): int
    {
        return (int) Configuration::get(self::CONFIG_PRODUCT);
    }

    /* ------------------------------------------------------------------ */
    /* Surcharge amount                                                    */
    /* ------------------------------------------------------------------ */

    /** Order total tax incl. with shipping, without any surcharge line already in the cart */
    public function baseTotal(Cart $cart): float
    {
        $total = (float) $cart->getOrderTotal(true, Cart::BOTH);
        foreach ($cart->getProducts() as $line) {
            if ((int) $line['id_product'] === $this->feeProductId()) {
                $total -= (float) $line['total_wt'];
            }
        }

        return max(0.0, $total);
    }

    /** Gross surcharge in the cart currency */
    public function feeFor(Cart $cart): float
    {
        $currency = new Currency((int) $cart->id_currency);
        $fixed = (float) Tools::convertPrice((float) Configuration::get(self::CONFIG_FIXED), $currency);

        return CshopCodFee::gross($this->baseTotal($cart), $fixed, (float) Configuration::get(self::CONFIG_PERCENT));
    }

    /**
     * Puts the surcharge in the cart (once) at a price tied to this cart only.
     * Returns false if it could not be added.
     */
    public function addFeeToCart(Cart $cart): bool
    {
        $idProduct = $this->feeProductId();
        $product = new Product($idProduct);
        if (!Validate::isLoadedObject($product)) {
            return false;
        }

        $this->removeFeeFromCart($cart);
        $this->ensureFeeStock($idProduct);
        $gross = $this->feeFor($cart);
        if ($gross <= 0) {
            return true;
        }
        $totalBefore = (float) $cart->getOrderTotal(true, Cart::BOTH);

        $addressField = Configuration::get('PS_TAX_ADDRESS_TYPE') === 'id_address_invoice' ? 'id_address_invoice' : 'id_address_delivery';
        $address = new Address((int) $cart->{$addressField});
        $rate = (float) $product->getTaxesRate(Validate::isLoadedObject($address) ? $address : null);

        $price = new SpecificPrice();
        $price->id_product = $idProduct;
        $price->id_product_attribute = 0;
        $price->id_cart = (int) $cart->id;
        $price->id_shop = 0;
        $price->id_shop_group = 0;
        // feeFor() is already in the cart currency: tie the price to it so it is not converted again
        $price->id_currency = (int) $cart->id_currency;
        $price->id_country = 0;
        $price->id_group = 0;
        $price->id_customer = 0;
        $price->price = CshopCodFee::net($gross, $rate);
        $price->from_quantity = 1;
        $price->reduction = 0;
        $price->reduction_tax = 1;
        $price->reduction_type = 'amount';
        $price->from = '0000-00-00 00:00:00';
        $price->to = '0000-00-00 00:00:00';
        if (!$price->add()) {
            return false;
        }
        $this->flushPriceCaches();

        $wasAllowed = self::$addingFee;
        self::$addingFee = true;
        try {
            $added = $cart->updateQty(1, $idProduct, 0, false, 'up', (int) $cart->id_address_delivery, null, false, true);
        } finally {
            self::$addingFee = $wasAllowed;
        }
        $this->flushPriceCaches();
        if (!$added) {
            return false;
        }

        // The extra line can move the cart over a free-shipping threshold or into a
        // percentage cart rule: correct the line once so the order grows by exactly $gross
        $diff = round($gross - ((float) $cart->getOrderTotal(true, Cart::BOTH) - $totalBefore), 2);
        if (abs($diff) >= 0.01) {
            $price->price = max(0.0, CshopCodFee::net(round($gross + $diff, 2), $rate));
            $price->update();
            $this->flushPriceCaches();
        }

        return true;
    }

    public function removeFeeFromCart(Cart $cart): void
    {
        $idProduct = $this->feeProductId();
        if (!$idProduct || !$cart->id) {
            return;
        }
        if ($this->cartHasFee($cart)) {
            $cart->deleteProduct($idProduct);
        }
        Db::getInstance()->delete(
            'specific_price',
            'id_product = ' . (int) $idProduct . ' AND id_cart = ' . (int) $cart->id
        );
        $this->flushPriceCaches();
    }

    private function flushPriceCaches(): void
    {
        if (method_exists('SpecificPrice', 'flushCache')) {
            SpecificPrice::flushCache();
        }
        if (method_exists('Product', 'flushPriceCache')) {
            Product::flushPriceCache();
        }
        if (method_exists('Cart', 'resetStaticCache')) {
            Cart::resetStaticCache();
        }
    }

    /* ------------------------------------------------------------------ */
    /* Hooks                                                               */
    /* ------------------------------------------------------------------ */

    public function hookPaymentOptions(array $params)
    {
        if (!$this->active || empty($params['cart']) || !$this->feeProductId()) {
            return [];
        }
        /** @var Cart $cart */
        $cart = $params['cart'];
        if ($cart->isVirtualCart() || !$this->checkCurrency($cart)) {
            return [];
        }

        $currency = new Currency((int) $cart->id_currency);
        $fee = $this->feeFor($cart);
        $feeText = $this->context->getCurrentLocale()->formatPrice($fee, $currency->iso_code);
        $totalText = $this->context->getCurrentLocale()->formatPrice($this->baseTotal($cart) + $fee, $currency->iso_code);

        $this->context->smarty->assign([
            'cshopcod_fee' => $feeText,
            'cshopcod_total' => $totalText,
            'cshopcod_fixed' => $this->context->getCurrentLocale()->formatPrice(
                (float) Tools::convertPrice((float) Configuration::get(self::CONFIG_FIXED), $currency),
                $currency->iso_code
            ),
            'cshopcod_percent' => str_replace('.', ',', (string) (float) Configuration::get(self::CONFIG_PERCENT)) . '%',
        ]);

        $option = new PaymentOption();
        $option->setModuleName($this->name)
            ->setCallToActionText($this->trans('Pay on delivery (+ %fee%)', ['%fee%' => $feeText], 'Modules.Cshopcod.Shop'))
            ->setAction($this->context->link->getModuleLink($this->name, 'validation', [], true))
            ->setAdditionalInformation($this->fetch('module:cshopcod/views/templates/hook/payment-info.tpl'));

        return [$option];
    }

    public function hookDisplayPaymentReturn(array $params)
    {
        if (!$this->active || empty($params['order']) || $params['order']->module !== $this->name) {
            return '';
        }
        $order = $params['order'];
        $this->context->smarty->assign([
            'cshopcod_total' => $this->context->getCurrentLocale()->formatPrice(
                (float) $order->total_paid,
                (new Currency((int) $order->id_currency))->iso_code
            ),
        ]);

        return $this->fetch('module:cshopcod/views/templates/hook/payment-return.tpl');
    }

    /**
     * The surcharge may be in a cart only while this module creates the order:
     * if a customer reaches the hidden product some other way, take it out.
     */
    public function hookActionCartSave(array $params): void
    {
        if (self::$addingFee || empty($params['cart']) || !$this->feeProductId()) {
            return;
        }
        $cart = $params['cart'];
        if ($cart instanceof Cart && $cart->id && $this->cartHasFee($cart) && !self::cartIsOrdered($cart)) {
            self::$addingFee = true;
            try {
                $this->removeFeeFromCart($cart);
            } finally {
                self::$addingFee = false;
            }
        }
    }

    private function checkCurrency(Cart $cart): bool
    {
        $currency = new Currency((int) $cart->id_currency);
        foreach ((array) $this->getCurrency((int) $cart->id_currency) as $allowed) {
            if ((int) $currency->id === (int) $allowed['id_currency']) {
                return true;
            }
        }

        return false;
    }

    /* ------------------------------------------------------------------ */
    /* Configuration                                                       */
    /* ------------------------------------------------------------------ */

    public function getContent(): string
    {
        $output = '';
        if (Tools::isSubmit('submitCshopcod')) {
            $fixed = CshopCodFee::parseAmount(Tools::getValue(self::CONFIG_FIXED));
            $percent = CshopCodFee::parseAmount(Tools::getValue(self::CONFIG_PERCENT));
            if ($fixed === null || $percent === null) {
                $output .= $this->displayError($this->trans('Enter valid amounts (0 or more).', [], 'Modules.Cshopcod.Admin'));
            } else {
                Configuration::updateValue(self::CONFIG_FIXED, (string) $fixed);
                Configuration::updateValue(self::CONFIG_PERCENT, (string) $percent);
                $output .= $this->displayConfirmation($this->trans('Settings saved.', [], 'Modules.Cshopcod.Admin'));
            }
        }

        $helper = new HelperForm();
        $helper->module = $this;
        $helper->name_controller = $this->name;
        $helper->token = Tools::getAdminTokenLite('AdminModules');
        $helper->currentIndex = AdminController::$currentIndex . '&configure=' . $this->name;
        $helper->submit_action = 'submitCshopcod';
        $helper->default_form_language = (int) $this->context->language->id;
        $helper->fields_value = [
            self::CONFIG_FIXED => Configuration::get(self::CONFIG_FIXED),
            self::CONFIG_PERCENT => Configuration::get(self::CONFIG_PERCENT),
        ];

        $productLink = $this->context->link->getAdminLink('AdminProducts', true, [
            'route' => 'admin_products_edit',
            'productId' => $this->feeProductId(),
        ]);

        return $output . $helper->generateForm([[
            'form' => [
                'legend' => ['title' => $this->trans('Cash on delivery surcharge', [], 'Modules.Cshopcod.Admin'), 'icon' => 'icon-money'],
                'description' => $this->trans(
                    'Surcharge = fixed amount + percentage of the order total (shipping and VAT included). It is added to the order as the product "Spese contrassegno" (reference %ref%): its tax rule decides the VAT.',
                    ['%ref%' => self::FEE_REFERENCE],
                    'Modules.Cshopcod.Admin'
                ) . ' <a href="' . htmlspecialchars($productLink) . '">' . $this->trans('Open the surcharge product', [], 'Modules.Cshopcod.Admin') . '</a>',
                'input' => [
                    [
                        'type' => 'text',
                        'name' => self::CONFIG_FIXED,
                        'label' => $this->trans('Fixed amount (VAT incl.)', [], 'Modules.Cshopcod.Admin'),
                        'suffix' => '€',
                        'class' => 'fixed-width-sm',
                    ],
                    [
                        'type' => 'text',
                        'name' => self::CONFIG_PERCENT,
                        'label' => $this->trans('Percentage of the order total', [], 'Modules.Cshopcod.Admin'),
                        'suffix' => '%',
                        'class' => 'fixed-width-sm',
                    ],
                ],
                'submit' => ['title' => $this->trans('Save', [], 'Admin.Actions')],
            ],
        ]]);
    }
}
