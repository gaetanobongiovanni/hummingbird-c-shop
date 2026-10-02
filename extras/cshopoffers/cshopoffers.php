<?php
/**
 * C-Shop offers: on the "Offerte" (prices-drop) page, when the discount is on a
 * combination that is not the default one, the product card shows that
 * combination (its price, old price, image and link) instead of the default
 * full-price one.
 *
 * Works on the search result before the cards are built
 * (hook actionProductSearchProviderRunQueryAfter, PrestaShop 9), so it also
 * works with ps_facetedsearch. Prices and specific prices are only read.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once __DIR__ . '/classes/CshopOffersPicker.php';

class Cshopoffers extends Module
{
    public function __construct()
    {
        $this->name = 'cshopoffers';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'C-Teck';
        $this->need_instance = 0;
        $this->ps_versions_compliancy = ['min' => '9.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans('C-Shop offers: discounted combination', [], 'Modules.Cshopoffers.Admin');
        $this->description = $this->trans(
            'On the offers page, shows the discounted combination of each product instead of the default one.',
            [],
            'Modules.Cshopoffers.Admin'
        );
    }

    public function isUsingNewTranslationSystem(): bool
    {
        return true;
    }

    public function install(): bool
    {
        return parent::install() && $this->registerHook('actionProductSearchProviderRunQueryAfter');
    }

    public function hookActionProductSearchProviderRunQueryAfter(array $params): void
    {
        $query = $params['query'] ?? null;
        $result = $params['result'] ?? null;
        if (!$query || !$result || !method_exists($query, 'getQueryType') || $query->getQueryType() !== 'prices-drop') {
            return;
        }

        $products = $result->getProducts();
        if (empty($products)) {
            return;
        }

        $candidates = $this->discountedCombinations(array_map(static function ($p) {
            return (int) $p['id_product'];
        }, $products));
        if (!$candidates) {
            return;
        }

        $changed = false;
        foreach ($products as &$product) {
            $idProduct = (int) $product['id_product'];
            if (empty($candidates[$idProduct])) {
                continue;
            }

            $default = !empty($product['id_product_attribute'])
                ? (int) $product['id_product_attribute']
                : (int) Product::getDefaultAttribute($idProduct);

            $options = [];
            foreach ($candidates[$idProduct] as $idProductAttribute) {
                $options[$idProductAttribute] = [
                    'reduction' => $this->reduction($idProduct, $idProductAttribute),
                    'available' => $this->isAvailable($idProduct, $idProductAttribute),
                ];
            }

            $pick = CshopOffersPicker::pick($this->reduction($idProduct, $default), $options);
            if ($pick !== null) {
                $product['id_product_attribute'] = $pick;
                $changed = true;
            }
        }
        unset($product);

        if ($changed) {
            $result->setProducts($products);
        }
    }

    /**
     * Combinations of these products that have a specific price for one unit,
     * valid today in this shop. Group, customer and currency are checked later
     * by Product::getPriceStatic().
     *
     * @param int[] $productIds
     *
     * @return array<int, int[]> id_product => [id_product_attribute, ...]
     */
    private function discountedCombinations(array $productIds): array
    {
        $productIds = array_filter(array_map('intval', $productIds));
        if (!$productIds) {
            return [];
        }
        $now = pSQL(date('Y-m-d H:i:s'));
        $rows = Db::getInstance()->executeS(
            'SELECT DISTINCT sp.id_product, sp.id_product_attribute
             FROM `' . _DB_PREFIX_ . 'specific_price` sp
             WHERE sp.id_product IN (' . implode(',', $productIds) . ')
               AND sp.id_product_attribute > 0
               AND sp.id_cart = 0
               AND sp.from_quantity <= 1
               AND sp.id_shop IN (0, ' . (int) $this->context->shop->id . ')
               AND (sp.`from` = \'0000-00-00 00:00:00\' OR sp.`from` <= \'' . $now . '\')
               AND (sp.`to` = \'0000-00-00 00:00:00\' OR sp.`to` >= \'' . $now . '\')'
        ) ?: [];

        $map = [];
        foreach ($rows as $row) {
            $map[(int) $row['id_product']][] = (int) $row['id_product_attribute'];
        }

        return $map;
    }

    /** Discount (tax incl.) for one unit of this combination, for the current visitor */
    private function reduction(int $idProduct, int $idProductAttribute): float
    {
        return (float) Product::getPriceStatic($idProduct, true, $idProductAttribute ?: null, 6, null, true);
    }

    private function isAvailable(int $idProduct, int $idProductAttribute): bool
    {
        if ((int) StockAvailable::getQuantityAvailableByProduct($idProduct, $idProductAttribute) > 0) {
            return true;
        }

        return (bool) Product::isAvailableWhenOutOfStock(StockAvailable::outOfStock($idProduct));
    }
}
