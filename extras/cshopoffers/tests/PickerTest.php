<?php
/**
 * Run: php extras/cshopoffers/tests/PickerTest.php
 */
define('CSHOPOFFERS_TEST', true);
require __DIR__ . '/../classes/CshopOffersPicker.php';

$failures = 0;
$check = static function (string $label, $actual, $expected) use (&$failures): void {
    if ($actual !== $expected) {
        ++$failures;
        echo "FAIL $label: expected " . var_export($expected, true) . ', got ' . var_export($actual, true) . "\n";
    }
};

$c = static function (float $reduction, bool $available = true): array {
    return ['reduction' => $reduction, 'available' => $available];
};

// Armadio Kubo: default 120x45x90 at full price, 120x45x200 discounted
$check('discounted variant replaces default', CshopOffersPicker::pick(0.0, [2202 => $c(176.08)]), 2202);
$check('default already on sale stays', CshopOffersPicker::pick(1.5, [2202 => $c(176.08)]), null);
$check('biggest saving wins', CshopOffersPicker::pick(0.0, [10 => $c(2.0), 11 => $c(5.0), 12 => $c(3.0)]), 11);
$check('available beats bigger saving', CshopOffersPicker::pick(0.0, [10 => $c(9.0, false), 11 => $c(2.0)]), 11);
$check('all unavailable: biggest saving', CshopOffersPicker::pick(0.0, [10 => $c(9.0, false), 11 => $c(2.0, false)]), 10);
$check('no real reduction', CshopOffersPicker::pick(0.0, [10 => $c(0.0)]), null);
$check('ignores id 0', CshopOffersPicker::pick(0.0, [0 => $c(5.0)]), null);
$check('no candidates', CshopOffersPicker::pick(0.0, []), null);

echo $failures ? "$failures failure(s)\n" : "All picker tests passed\n";
exit($failures ? 1 : 0);
