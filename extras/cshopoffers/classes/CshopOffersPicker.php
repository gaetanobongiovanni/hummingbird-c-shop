<?php
/**
 * Chooses which combination a listing card should show for a product on sale.
 * Pure logic, unit tested in tests/PickerTest.php.
 */
if (!defined('_PS_VERSION_') && !defined('CSHOPOFFERS_TEST')) {
    exit;
}

class CshopOffersPicker
{
    /**
     * @param float $defaultReduction reduction of the combination the card would show anyway
     * @param array<int, array{reduction: float, available: bool}> $candidates keyed by id_product_attribute
     *
     * @return int|null combination to show instead, or null to keep the default one
     */
    public static function pick(float $defaultReduction, array $candidates): ?int
    {
        // The default combination is already on sale: nothing to change
        if ($defaultReduction > 0) {
            return null;
        }

        $best = null;
        $bestScore = null;
        foreach ($candidates as $idProductAttribute => $candidate) {
            if ((int) $idProductAttribute <= 0 || $candidate['reduction'] <= 0) {
                continue;
            }
            // Prefer what can be bought now, then the biggest saving
            $score = [$candidate['available'] ? 1 : 0, (float) $candidate['reduction']];
            if ($bestScore === null || $score > $bestScore) {
                $best = (int) $idProductAttribute;
                $bestScore = $score;
            }
        }

        return $best;
    }
}
