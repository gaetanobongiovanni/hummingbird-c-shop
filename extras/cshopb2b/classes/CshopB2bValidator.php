<?php
/**
 * C-Shop B2B — Italian business data validation (pure functions, no PrestaShop
 * dependency, unit tested in tests/ValidatorTest.php).
 */
if (!defined('_PS_VERSION_') && !defined('CSHOPB2B_TEST')) {
    exit;
}

class CshopB2bValidator
{
    public const TYPE_PRIVATE = 'privato';
    public const TYPE_COMPANY = 'azienda';
    public const TYPE_RESELLER = 'rivenditore';
    public const TYPE_PUBLIC = 'ente';

    public const FORM_SOLE = 'ditta';
    public const FORM_COMPANY = 'societa';

    public const VISURA_MAX_BYTES = 5242880; // 5 MB

    /** @var array<string, string> allowed visura MIME types => stored extension */
    public const VISURA_MIME = [
        'application/pdf' => 'pdf',
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
    ];

    public static function types(): array
    {
        return [self::TYPE_PRIVATE, self::TYPE_COMPANY, self::TYPE_RESELLER, self::TYPE_PUBLIC];
    }

    public static function isBusiness(string $type): bool
    {
        return in_array($type, [self::TYPE_COMPANY, self::TYPE_RESELLER], true);
    }

    public static function normalize(string $value): string
    {
        return strtoupper(preg_replace('/\s+/', '', $value));
    }

    /** Italian VAT number: 11 digits with Luhn-style check digit (also used by numeric codici fiscali). */
    public static function isPartitaIva(string $value): bool
    {
        $value = self::normalize($value);
        if (strpos($value, 'IT') === 0) {
            $value = substr($value, 2);
        }
        if (!preg_match('/^\d{11}$/', $value) || $value === '00000000000') {
            return false;
        }

        $sum = 0;
        for ($i = 0; $i < 11; ++$i) {
            $digit = (int) $value[$i];
            if ($i % 2 === 1) {
                $digit *= 2;
                if ($digit > 9) {
                    $digit -= 9;
                }
            }
            $sum += $digit;
        }

        return $sum % 10 === 0;
    }

    /** Personal codice fiscale (16 chars) with control character, omocodia allowed. */
    public static function isCodiceFiscalePersona(string $value): bool
    {
        $value = self::normalize($value);
        if (!preg_match('/^[A-Z]{6}[0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]$/', $value)) {
            return false;
        }

        $odd = [
            '0' => 1, '1' => 0, '2' => 5, '3' => 7, '4' => 9, '5' => 13, '6' => 15, '7' => 17, '8' => 19, '9' => 21,
            'A' => 1, 'B' => 0, 'C' => 5, 'D' => 7, 'E' => 9, 'F' => 13, 'G' => 15, 'H' => 17, 'I' => 19, 'J' => 21,
            'K' => 2, 'L' => 4, 'M' => 18, 'N' => 20, 'O' => 11, 'P' => 3, 'Q' => 6, 'R' => 8, 'S' => 12, 'T' => 14,
            'U' => 16, 'V' => 10, 'W' => 22, 'X' => 25, 'Y' => 24, 'Z' => 23,
        ];

        $sum = 0;
        for ($i = 0; $i < 15; ++$i) {
            $char = $value[$i];
            if ($i % 2 === 0) {
                $sum += $odd[$char];
            } else {
                $sum += ctype_digit($char) ? (int) $char : ord($char) - 65;
            }
        }

        return chr(65 + $sum % 26) === $value[15];
    }

    /** Numeric codice fiscale of a company or public body (11 digits). */
    public static function isCodiceFiscaleNumerico(string $value): bool
    {
        $value = self::normalize($value);

        return preg_match('/^\d{11}$/', $value) === 1 && self::isPartitaIva($value);
    }

    /** Codice destinatario SDI for businesses: 7 alphanumeric characters. */
    public static function isCodiceSdi(string $value): bool
    {
        return preg_match('/^[A-Z0-9]{7}$/', self::normalize($value)) === 1;
    }

    /** Codice univoco ufficio (IPA) for public bodies: 6 alphanumeric characters. */
    public static function isCodiceUnivocoUfficio(string $value): bool
    {
        return preg_match('/^[A-Z0-9]{6}$/', self::normalize($value)) === 1;
    }

    public static function isEmail(string $value): bool
    {
        return filter_var(trim($value), FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * Validates the posted business data.
     *
     * @param array<string, string> $data keys: type, legal_form, company, vat, tax_code, sdi, ipa, pec
     *
     * @return array<string, string> field name => error code (empty when valid)
     */
    public static function validate(array $data): array
    {
        $errors = [];
        $type = $data['type'] ?? '';

        if (!in_array($type, self::types(), true)) {
            return ['cs_customer_type' => 'type'];
        }
        if ($type === self::TYPE_PRIVATE) {
            return [];
        }

        $company = trim($data['company'] ?? '');
        $vat = self::normalize($data['vat'] ?? '');
        $taxCode = self::normalize($data['tax_code'] ?? '');
        $pec = trim($data['pec'] ?? '');

        if ($company === '' || mb_strlen($company) > 255) {
            $errors['cs_company'] = 'required';
        }

        if ($pec !== '' && !self::isEmail($pec)) {
            $errors['cs_pec'] = 'pec';
        }

        if (self::isBusiness($type)) {
            $legalForm = $data['legal_form'] ?? '';
            if (!in_array($legalForm, [self::FORM_SOLE, self::FORM_COMPANY], true)) {
                $errors['cs_legal_form'] = 'required';
            }

            if (!self::isPartitaIva($vat)) {
                $errors['cs_vat'] = $vat === '' ? 'required' : 'vat';
            }

            // sole trader: the owner's personal code; company: numeric code (often equal to the VAT number)
            if ($taxCode === '') {
                $errors['cs_tax_code'] = 'required';
            } elseif ($legalForm === self::FORM_SOLE && !self::isCodiceFiscalePersona($taxCode)) {
                $errors['cs_tax_code'] = 'tax_code_person';
            } elseif ($legalForm === self::FORM_COMPANY && !self::isCodiceFiscaleNumerico($taxCode)) {
                $errors['cs_tax_code'] = 'tax_code_company';
            }

            // e-invoicing: SDI recipient code or PEC
            $sdi = self::normalize($data['sdi'] ?? '');
            if ($sdi === '' && $pec === '') {
                $errors['cs_sdi'] = 'sdi_or_pec';
            } elseif ($sdi !== '' && !self::isCodiceSdi($sdi)) {
                $errors['cs_sdi'] = 'sdi';
            }
        }

        if ($type === self::TYPE_PUBLIC) {
            if ($vat !== '' && !self::isPartitaIva($vat)) {
                $errors['cs_vat'] = 'vat';
            }
            if (!self::isCodiceFiscaleNumerico($taxCode)) {
                $errors['cs_tax_code'] = $taxCode === '' ? 'required' : 'tax_code_company';
            }
            if (!self::isCodiceUnivocoUfficio($data['ipa'] ?? '')) {
                $errors['cs_ipa'] = ($data['ipa'] ?? '') === '' ? 'required' : 'ipa';
            }
        }

        return $errors;
    }

    /**
     * Validates an uploaded visura ($_FILES entry). Returns an error code or ''.
     *
     * @param array|null $file
     * @param callable|null $mimeDetector fn(string $path): string (tests inject one)
     */
    public static function validateVisura($file, ?callable $mimeDetector = null): string
    {
        if (!is_array($file) || ($file['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
            return 'visura_required';
        }
        if (($file['error'] ?? UPLOAD_ERR_OK) !== UPLOAD_ERR_OK) {
            return in_array($file['error'], [UPLOAD_ERR_INI_SIZE, UPLOAD_ERR_FORM_SIZE], true) ? 'visura_size' : 'visura_upload';
        }
        if ((int) ($file['size'] ?? 0) <= 0 || (int) $file['size'] > self::VISURA_MAX_BYTES) {
            return 'visura_size';
        }

        $detect = $mimeDetector ?? static function (string $path): string {
            $finfo = new finfo(FILEINFO_MIME_TYPE);

            return (string) $finfo->file($path);
        };

        return isset(self::VISURA_MIME[$detect((string) $file['tmp_name'])]) ? '' : 'visura_type';
    }
}
