{**
 * C-Shop — normalise product data for templates (data contract).
 *
 * Native PrestaShop fields are always used. A dedicated module (e.g. the EDI
 * import module) MAY enrich products through the `actionPresentProduct`,
 * `actionPresentProductListing` and `actionPresentCartProduct` hooks with:
 *   $presentedProduct->appendArray(['cshop' => [
 *     'supplier_code'  => string,  // overrides supplier_reference
 *     'oem_code'       => string,  // overrides mpn
 *     'pack_quantity'  => int,     // pieces per pack / selling unit
 *     'pack_label'     => string,  // e.g. "confezione", "scatola"
 *     'order_multiple' => int,     // orderable multiples (qty step)
 *     'min_quantity'   => int,     // overrides minimal_quantity if greater
 *     'lead_time'      => string,  // delivery lead time text
 *     'documents'      => [['name' => string, 'url' => string, 'size' => string], …],
 *   ]]);
 * Nothing is invented: every value is empty when not provided.
 *
 * In: $product. Out (parent scope): $cs (array)
 *}
{$csExtra = []}
{if !empty($product.cshop)}{$csExtra = $product.cshop}{/if}

{* Displayed minimum: product/combination minimal quantity (or the module's, if greater) *}
{$csMinOrder = $product.minimal_quantity|default:1}
{$csMinOrder = $csMinOrder + 0}
{if !empty($csExtra.min_quantity) && $csExtra.min_quantity > $csMinOrder}{$csMinOrder = $csExtra.min_quantity + 0}{/if}
{if $csMinOrder < 1}{$csMinOrder = 1}{/if}

{* Input minimum: core `quantity_required` already subtracts what is in the cart *}
{$csMin = $product.quantity_required|default:$csMinOrder}
{$csMin = $csMin + 0}
{if !empty($csExtra.min_quantity) && $csExtra.min_quantity > $csMin}{$csMin = $csExtra.min_quantity + 0}{/if}
{if $csMin < 1}{$csMin = 1}{/if}

{$csStep = 1}
{if !empty($csExtra.order_multiple) && $csExtra.order_multiple > 1}{$csStep = $csExtra.order_multiple + 0}{/if}

{$csPack = 0}
{if !empty($csExtra.pack_quantity)}{$csPack = $csExtra.pack_quantity + 0}{/if}

{assign var='cs' scope='parent' value=[
  'reference' => $product.reference|default:'',
  'supplier_code' => $csExtra.supplier_code|default:$product.supplier_reference|default:'',
  'oem_code' => $csExtra.oem_code|default:$product.mpn|default:'',
  'ean' => $product.ean13|default:'',
  'brand' => $product.manufacturer_name|default:'',
  'min' => $csMin,
  'min_order' => $csMinOrder,
  'step' => $csStep,
  'pack_quantity' => $csPack,
  'pack_label' => $csExtra.pack_label|default:'',
  'lead_time' => $csExtra.lead_time|default:'',
  'documents' => $csExtra.documents|default:[]
]}
