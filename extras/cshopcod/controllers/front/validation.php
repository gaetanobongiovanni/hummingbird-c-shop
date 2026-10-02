<?php
/**
 * Creates the cash on delivery order: adds the surcharge line to the cart, then
 * validates the order for the new total. Same checks as ps_cashondelivery.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

class CshopcodValidationModuleFrontController extends ModuleFrontController
{
    /** @var Cshopcod */
    public $module;

    public function postProcess()
    {
        $cart = $this->context->cart;
        if (!Validate::isLoadedObject($cart)
            || $cart->id_customer == 0
            || $cart->id_address_delivery == 0
            || $cart->id_address_invoice == 0
            || $cart->isVirtualCart()
            || !$this->module->active
        ) {
            Tools::redirect($this->context->link->getPageLink('order', true, null, ['step' => 1]));
        }

        $authorized = false;
        foreach (Module::getPaymentModules() as $module) {
            if ($module['name'] === $this->module->name) {
                $authorized = true;
                break;
            }
        }
        if (!$authorized) {
            exit($this->trans('This payment method is not available.', [], 'Modules.Cshopcod.Shop'));
        }

        $customer = new Customer((int) $cart->id_customer);
        if (!Validate::isLoadedObject($customer)) {
            Tools::redirect($this->context->link->getPageLink('order', true, null, ['step' => 1]));
        }

        // Double click / reload: the cart is already an order, do not touch it
        $confirmation = $this->context->link->getPageLink('order-confirmation', true, null, [
            'id_cart' => (int) $cart->id,
            'id_module' => (int) $this->module->id,
            'key' => $customer->secure_key,
        ]);
        if (Cshopcod::cartIsOrdered($cart)) {
            Tools::redirect($confirmation . '&id_order=' . (int) Order::getIdByCartId((int) $cart->id));
        }
        // Two requests at once for the same cart: only one creates the order
        $lock = 'cshopcod_' . (int) $cart->id;
        if (!(int) Db::getInstance()->getValue("SELECT GET_LOCK('" . pSQL($lock) . "', 10)")) {
            Tools::redirect($this->context->link->getPageLink('order', true, null, ['step' => 3]));
        }
        if (Cshopcod::cartIsOrdered($cart)) {
            Db::getInstance()->getValue("SELECT RELEASE_LOCK('" . pSQL($lock) . "')");
            Tools::redirect($confirmation . '&id_order=' . (int) Order::getIdByCartId((int) $cart->id));
        }

        Cshopcod::allowFeeInCart(true);
        try {
            if (!$this->module->addFeeToCart($cart)) {
                $this->module->removeFeeFromCart($cart);
                Tools::redirect($this->context->link->getPageLink('order', true, null, ['step' => 3]));
            }

            $state = (int) Configuration::get('PS_OS_COD_VALIDATION') ?: (int) Configuration::get('PS_OS_PREPARATION');
            $total = (float) $cart->getOrderTotal(true, Cart::BOTH);

            $this->module->validateOrder(
                (int) $cart->id,
                $state,
                $total,
                $this->trans('Cash on delivery', [], 'Modules.Cshopcod.Shop'),
                null,
                [],
                (int) $cart->id_currency,
                false,
                $customer->secure_key
            );
        } catch (Throwable $e) {
            // Leave the cart as the customer had it, without the surcharge
            if (!Cshopcod::cartIsOrdered($cart)) {
                $this->module->removeFeeFromCart($cart);
            }
            PrestaShopLogger::addLog('cshopcod: ' . $e->getMessage(), 3, null, 'Cart', (int) $cart->id, true);
            Tools::redirect($this->context->link->getPageLink('order', true, null, ['step' => 3]));
        } finally {
            Cshopcod::allowFeeInCart(false);
            Db::getInstance()->getValue("SELECT RELEASE_LOCK('" . pSQL($lock) . "')");
        }

        Tools::redirect($this->context->link->getPageLink('order-confirmation', true, null, [
            'id_cart' => (int) $cart->id,
            'id_module' => (int) $this->module->id,
            'id_order' => (int) $this->module->currentOrder,
            'key' => $customer->secure_key,
        ]));
    }
}
