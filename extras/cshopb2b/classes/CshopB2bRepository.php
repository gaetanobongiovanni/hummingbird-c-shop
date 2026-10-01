<?php
/**
 * C-Shop B2B — persistence: business data table, customer groups and the
 * private storage of the uploaded visure.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

class CshopB2bRepository
{
    public const TABLE = 'cshopb2b_customer';

    public const STATUS_NONE = 'none';
    public const STATUS_PENDING = 'pending';
    public const STATUS_APPROVED = 'approved';
    public const STATUS_REJECTED = 'rejected';

    /** Configuration keys holding the id of each group created by the module */
    public const GROUP_KEYS = [
        'company' => 'CSHOPB2B_GROUP_COMPANY',
        'reseller_pending' => 'CSHOPB2B_GROUP_RESELLER_PENDING',
        'reseller' => 'CSHOPB2B_GROUP_RESELLER',
        'public' => 'CSHOPB2B_GROUP_PUBLIC',
    ];

    /** Group names, Italian shop (all languages get the same label) */
    public const GROUP_NAMES = [
        'company' => 'Aziende',
        'reseller_pending' => 'Rivenditori in verifica',
        'reseller' => 'Rivenditori',
        'public' => 'Enti pubblici',
    ];

    public static function installSchema(): bool
    {
        $sql = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . self::TABLE . '` (
            `id_customer` INT UNSIGNED NOT NULL,
            `customer_type` VARCHAR(16) NOT NULL,
            `legal_form` VARCHAR(16) NOT NULL DEFAULT \'\',
            `company` VARCHAR(255) NOT NULL DEFAULT \'\',
            `vat_number` VARCHAR(32) NOT NULL DEFAULT \'\',
            `tax_code` VARCHAR(32) NOT NULL DEFAULT \'\',
            `sdi_code` VARCHAR(7) NOT NULL DEFAULT \'\',
            `ipa_code` VARCHAR(6) NOT NULL DEFAULT \'\',
            `pec` VARCHAR(255) NOT NULL DEFAULT \'\',
            `visura_file` VARCHAR(64) NOT NULL DEFAULT \'\',
            `visura_name` VARCHAR(255) NOT NULL DEFAULT \'\',
            `visura_mime` VARCHAR(64) NOT NULL DEFAULT \'\',
            `status` VARCHAR(16) NOT NULL DEFAULT \'none\',
            `note` TEXT NULL,
            `date_add` DATETIME NOT NULL,
            `date_upd` DATETIME NOT NULL,
            PRIMARY KEY (`id_customer`),
            KEY `status` (`status`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4';

        return Db::getInstance()->execute($sql);
    }

    public static function get(int $idCustomer): ?array
    {
        $row = Db::getInstance()->getRow(
            'SELECT * FROM `' . _DB_PREFIX_ . self::TABLE . '` WHERE `id_customer` = ' . (int) $idCustomer
        );

        return $row ?: null;
    }

    public static function save(int $idCustomer, array $data): bool
    {
        $now = date('Y-m-d H:i:s');
        $row = [
            'id_customer' => (int) $idCustomer,
            'customer_type' => pSQL($data['customer_type']),
            'legal_form' => pSQL($data['legal_form'] ?? ''),
            'company' => pSQL($data['company'] ?? ''),
            'vat_number' => pSQL($data['vat_number'] ?? ''),
            'tax_code' => pSQL($data['tax_code'] ?? ''),
            'sdi_code' => pSQL($data['sdi_code'] ?? ''),
            'ipa_code' => pSQL($data['ipa_code'] ?? ''),
            'pec' => pSQL($data['pec'] ?? ''),
            'visura_file' => pSQL($data['visura_file'] ?? ''),
            'visura_name' => pSQL($data['visura_name'] ?? ''),
            'visura_mime' => pSQL($data['visura_mime'] ?? ''),
            'status' => pSQL($data['status'] ?? self::STATUS_NONE),
            'date_add' => $now,
            'date_upd' => $now,
        ];

        return Db::getInstance()->insert(self::TABLE, $row, false, true, Db::REPLACE);
    }

    public static function setStatus(int $idCustomer, string $status, string $note = ''): bool
    {
        return Db::getInstance()->update(
            self::TABLE,
            ['status' => pSQL($status), 'note' => pSQL($note), 'date_upd' => date('Y-m-d H:i:s')],
            '`id_customer` = ' . (int) $idCustomer
        );
    }

    public static function countPending(): int
    {
        return (int) Db::getInstance()->getValue(
            'SELECT COUNT(*) FROM `' . _DB_PREFIX_ . self::TABLE . '` WHERE `status` = \'' . self::STATUS_PENDING . '\''
        );
    }

    // ---------------------------------------------------------------------
    // Customer groups
    // ---------------------------------------------------------------------

    public static function groupId(string $key): int
    {
        return (int) Configuration::get(self::GROUP_KEYS[$key]);
    }

    /**
     * Creates the B2B groups once. A new group gets no access to categories,
     * carriers or modules by default (its customers would see an empty shop),
     * so the access of the standard "Customer" group is copied.
     */
    public static function installGroups(): bool
    {
        $customerGroup = (int) Configuration::get('PS_CUSTOMER_GROUP');
        $source = new Group($customerGroup);

        foreach (self::GROUP_NAMES as $key => $name) {
            $existing = self::groupId($key);
            if ($existing && Validate::isLoadedObject(new Group($existing))) {
                continue;
            }

            $group = new Group();
            foreach (Language::getIDs(false) as $idLang) {
                $group->name[$idLang] = $name;
            }
            $group->reduction = 0;
            // same price display as standard customers; switch to tax excluded per group if wanted
            $group->price_display_method = (int) $source->price_display_method;
            $group->show_prices = 1;
            if (!$group->add()) {
                return false;
            }

            self::copyGroupAccess($customerGroup, (int) $group->id);
            Configuration::updateValue(self::GROUP_KEYS[$key], (int) $group->id);
        }

        return true;
    }

    private static function copyGroupAccess(int $fromGroup, int $toGroup): void
    {
        $db = Db::getInstance();
        $db->execute('INSERT IGNORE INTO `' . _DB_PREFIX_ . 'category_group` (`id_category`, `id_group`)
            SELECT `id_category`, ' . $toGroup . ' FROM `' . _DB_PREFIX_ . 'category_group` WHERE `id_group` = ' . $fromGroup);
        // Group::add() opens every carrier to the new group: align it with the Customer group instead
        $db->execute('DELETE FROM `' . _DB_PREFIX_ . 'carrier_group` WHERE `id_group` = ' . $toGroup);
        $db->execute('INSERT IGNORE INTO `' . _DB_PREFIX_ . 'carrier_group` (`id_carrier`, `id_group`)
            SELECT `id_carrier`, ' . $toGroup . ' FROM `' . _DB_PREFIX_ . 'carrier_group` WHERE `id_group` = ' . $fromGroup);
        $db->execute('INSERT IGNORE INTO `' . _DB_PREFIX_ . 'module_group` (`id_module`, `id_shop`, `id_group`)
            SELECT `id_module`, `id_shop`, ' . $toGroup . ' FROM `' . _DB_PREFIX_ . 'module_group` WHERE `id_group` = ' . $fromGroup);
    }

    /**
     * Puts the customer in the group matching its type and makes it the default
     * group (prices and group discounts follow the default group).
     */
    public static function assignGroup(Customer $customer, string $groupKey): void
    {
        $target = self::groupId($groupKey);
        if (!$target) {
            return;
        }

        $managed = array_filter(array_map([self::class, 'groupId'], array_keys(self::GROUP_KEYS)));
        $groups = array_values(array_diff(array_map('intval', $customer->getGroups()), $managed));
        $groups[] = $target;

        $customer->updateGroup(array_unique($groups));
        $customer->id_default_group = $target;
        $customer->update();
        Customer::resetStaticCache();
    }

    // ---------------------------------------------------------------------
    // Visura storage: outside the web root conventions, random file names
    // ---------------------------------------------------------------------

    public static function storageDir(): string
    {
        // download/ is PrestaShop's private folder for virtual products (denied to the web)
        $dir = _PS_DOWNLOAD_DIR_ . 'cshopb2b/';
        if (!is_dir($dir)) {
            @mkdir($dir, 0750, true);
        }
        if (!file_exists($dir . '.htaccess')) {
            @file_put_contents($dir . '.htaccess', "Require all denied\nDeny from all\n");
        }
        if (!file_exists($dir . 'index.php')) {
            @file_put_contents($dir . 'index.php', "<?php\nheader('Location: ../../');\nexit;\n");
        }

        return $dir;
    }

    /**
     * Moves the uploaded file to private storage.
     *
     * @return array{file: string, name: string, mime: string}|null
     */
    public static function storeVisura(array $upload): ?array
    {
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = (string) $finfo->file($upload['tmp_name']);
        if (!isset(CshopB2bValidator::VISURA_MIME[$mime])) {
            return null;
        }

        $file = bin2hex(random_bytes(20));
        if (!move_uploaded_file($upload['tmp_name'], self::storageDir() . $file)) {
            return null;
        }
        @chmod(self::storageDir() . $file, 0640);

        $name = preg_replace('/[^\w.\- ]+/u', '_', basename((string) $upload['name']));

        return ['file' => $file, 'name' => mb_substr($name, 0, 200), 'mime' => $mime];
    }

    public static function visuraPath(array $row): ?string
    {
        if (empty($row['visura_file']) || !preg_match('/^[a-f0-9]{40}$/', $row['visura_file'])) {
            return null;
        }
        $path = self::storageDir() . $row['visura_file'];

        return is_file($path) ? $path : null;
    }
}
