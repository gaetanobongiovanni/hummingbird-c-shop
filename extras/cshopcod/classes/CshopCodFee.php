<?php
/**
 * Cash on delivery surcharge arithmetic, kept free of PrestaShop classes so it
 * can be unit tested (tests/FeeTest.php).
 */
if (!defined('_PS_VERSION_') && !defined('CSHOPCOD_TEST')) {
    exit;
}

class CshopCodFee
{
    /**
     * Gross surcharge (tax included): fixed part + percentage of the order total.
     *
     * @param float $orderTotal order total tax incl., shipping incl., surcharge excluded
     * @param float $fixed fixed part, already in the cart currency
     * @param float $percent percentage, e.g. 1.4
     */
    public static function gross(float $orderTotal, float $fixed, float $percent): float
    {
        $fee = max(0.0, $fixed) + max(0.0, $orderTotal) * max(0.0, $percent) / 100;

        return round($fee, 2);
    }

    /**
     * Price tax excluded to give the surcharge product so that, with the tax rate
     * applied, the customer pays exactly the gross amount.
     */
    public static function net(float $gross, float $taxRate): float
    {
        return round($gross / (1 + max(0.0, $taxRate) / 100), 6);
    }

    /** Parses a back-office number, accepting the Italian decimal comma. */
    public static function parseAmount($value): ?float
    {
        $value = str_replace([' ', ','], ['', '.'], trim((string) $value));
        if ($value === '' || !is_numeric($value) || (float) $value < 0) {
            return null;
        }

        return (float) $value;
    }
}
