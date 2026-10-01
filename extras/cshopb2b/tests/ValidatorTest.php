<?php
/**
 * Run: php extras/cshopb2b/tests/ValidatorTest.php
 */
define('CSHOPB2B_TEST', true);
require __DIR__ . '/../classes/CshopB2bValidator.php';

$failures = 0;
$check = static function (string $label, $actual, $expected) use (&$failures): void {
    if ($actual !== $expected) {
        ++$failures;
        echo "FAIL $label: expected " . var_export($expected, true) . ', got ' . var_export($actual, true) . "\n";
    }
};

// Partita IVA (C-COMMERCE SRL) and checksum errors
$check('piva valid', CshopB2bValidator::isPartitaIva('03031690831'), true);
$check('piva with IT prefix and spaces', CshopB2bValidator::isPartitaIva('IT 0303 1690 831'), true);
$check('piva bad check digit', CshopB2bValidator::isPartitaIva('03031690832'), false);
$check('piva too short', CshopB2bValidator::isPartitaIva('1234567890'), false);
$check('piva zeros', CshopB2bValidator::isPartitaIva('00000000000'), false);

// Codice fiscale persona (classic example) and omocodia
$check('cf valid', CshopB2bValidator::isCodiceFiscalePersona('RSSMRA85T10A562S'), true);
$check('cf lowercase', CshopB2bValidator::isCodiceFiscalePersona('rssmra85t10a562s'), true);
$check('cf bad check char', CshopB2bValidator::isCodiceFiscalePersona('RSSMRA85T10A562T'), false);
$check('cf numeric company', CshopB2bValidator::isCodiceFiscaleNumerico('03031690831'), true);

$check('sdi', CshopB2bValidator::isCodiceSdi('m5uxcr1'), true);
$check('sdi short', CshopB2bValidator::isCodiceSdi('ABC12'), false);
$check('ipa', CshopB2bValidator::isCodiceUnivocoUfficio('UF1234'), true);

// Whole-form validation
$check('private needs nothing', CshopB2bValidator::validate(['type' => 'privato']), []);
$check('unknown type', CshopB2bValidator::validate(['type' => 'x']), ['cs_customer_type' => 'type']);

$company = [
    'type' => 'azienda', 'legal_form' => 'societa', 'company' => 'C-COMMERCE SRL',
    'vat' => '03031690831', 'tax_code' => '03031690831', 'sdi' => 'M5UXCR1', 'pec' => '',
];
$check('company valid', CshopB2bValidator::validate($company), []);
$check('company with PEC only', CshopB2bValidator::validate(['sdi' => '', 'pec' => 'c-commerce@pec.it'] + $company), []);
$check('company no SDI no PEC', CshopB2bValidator::validate(['sdi' => '', 'pec' => ''] + $company), ['cs_sdi' => 'sdi_or_pec']);
$check('company personal CF refused', CshopB2bValidator::validate(['tax_code' => 'RSSMRA85T10A562S'] + $company), ['cs_tax_code' => 'tax_code_company']);

$sole = ['legal_form' => 'ditta', 'tax_code' => 'RSSMRA85T10A562S', 'type' => 'rivenditore'] + $company;
$check('sole trader reseller valid', CshopB2bValidator::validate($sole), []);
$check('sole trader numeric CF refused', CshopB2bValidator::validate(['tax_code' => '03031690831'] + $sole), ['cs_tax_code' => 'tax_code_person']);
$check('missing legal form', CshopB2bValidator::validate(['legal_form' => ''] + $sole)['cs_legal_form'] ?? null, 'required');

$ente = ['type' => 'ente', 'company' => 'Comune di Raccuja', 'vat' => '', 'tax_code' => '03031690831', 'ipa' => 'UF1234', 'pec' => ''];
$check('public body valid without VAT', CshopB2bValidator::validate($ente), []);
$check('public body needs IPA', CshopB2bValidator::validate(['ipa' => ''] + $ente), ['cs_ipa' => 'required']);
$check('bad PEC', CshopB2bValidator::validate(['pec' => 'not-an-email'] + $ente), ['cs_pec' => 'pec']);

// Visura upload
$pdf = static fn (string $p): string => 'application/pdf';
$exe = static fn (string $p): string => 'application/x-dosexec';
$ok = ['error' => UPLOAD_ERR_OK, 'size' => 120000, 'tmp_name' => '/tmp/x'];
$check('visura ok', CshopB2bValidator::validateVisura($ok, $pdf), '');
$check('visura missing', CshopB2bValidator::validateVisura(null), 'visura_required');
$check('visura not sent', CshopB2bValidator::validateVisura(['error' => UPLOAD_ERR_NO_FILE]), 'visura_required');
$check('visura too big', CshopB2bValidator::validateVisura(['size' => 6000000] + $ok, $pdf), 'visura_size');
$check('visura wrong type', CshopB2bValidator::validateVisura($ok, $exe), 'visura_type');

echo $failures === 0 ? "All validator tests passed\n" : "$failures failure(s)\n";
exit($failures === 0 ? 0 : 1);
