<?php
/**
 * 1.0.2: the banner has its own on/off switch, on by default, independent of
 * the statistics/marketing categories.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

function upgrade_module_1_0_2($module)
{
    return Configuration::updateValue(Cshopcookie::CONFIG_ENABLED, 1);
}
