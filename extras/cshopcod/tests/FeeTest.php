<?php
/**
 * Run: php extras/cshopcod/tests/FeeTest.php
 */
define('CSHOPCOD_TEST', true);
require __DIR__ . '/../classes/CshopCodFee.php';

$failures = 0;
$check = static function (string $label, $actual, $expected) use (&$failures): void {
    if ($actual !== $expected) {
        ++$failures;
        echo "FAIL $label: expected " . var_export($expected, true) . ', got ' . var_export($actual, true) . "\n";
    }
};

// 2.50 + 1.4% (C-Shop settings)
$check('100 EUR order', CshopCodFee::gross(100.0, 2.5, 1.4), 3.9);
$check('201.98 EUR order', CshopCodFee::gross(201.98, 2.5, 1.4), 5.33); // 2.5 + 2.82772
$check('empty order', CshopCodFee::gross(0.0, 2.5, 1.4), 2.5);
$check('negatives ignored', CshopCodFee::gross(-10.0, -1.0, -1.0), 0.0);

// Net price at 22% VAT gives back the gross amount once taxed and rounded
foreach ([3.9, 5.33, 2.5, 17.07, 0.01] as $gross) {
    $check("net roundtrip $gross", round(CshopCodFee::net($gross, 22.0) * 1.22, 2), $gross);
}
$check('net without tax', CshopCodFee::net(3.9, 0.0), 3.9);

$check('parse comma', CshopCodFee::parseAmount('1,4'), 1.4);
$check('parse dot', CshopCodFee::parseAmount(' 2.50 '), 2.5);
$check('parse zero', CshopCodFee::parseAmount('0'), 0.0);
$check('parse empty', CshopCodFee::parseAmount(''), null);
$check('parse text', CshopCodFee::parseAmount('abc'), null);
$check('parse negative', CshopCodFee::parseAmount('-1'), null);

echo $failures ? "$failures failure(s)\n" : "All fee tests passed\n";
exit($failures ? 1 : 0);
