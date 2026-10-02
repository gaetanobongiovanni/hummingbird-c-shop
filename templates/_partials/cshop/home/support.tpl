{**
 * C-Shop homepage — reassurance messages (blockreassurance: delivery,
 * payment, returns, configured in Back Office). The "Assistance" card was
 * removed: contacts are in the info bar, footer and contact page.
 *}
<section class="cs-section cs-section--alt" aria-label="{l s='Our services' d='Shop.Theme.Cshop'}">
  <div class="container">
    <div class="cs-support cs-support--full cs-panel">
      <div class="cs-support__delivery">
        {widget name='blockreassurance'}
      </div>
    </div>
  </div>
</section>
