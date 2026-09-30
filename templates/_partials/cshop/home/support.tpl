{**
 * C-Shop homepage — assistance and delivery information.
 * Data: ps_contactinfo (shop contact details) + blockreassurance (delivery /
 * payment messages configured in Back Office).
 *}
<section class="cs-section cs-section--alt" aria-labelledby="cs-home-support-title">
  <div class="container cs-support">
    <div class="cs-support__contact cs-card">
      <h2 id="cs-home-support-title" class="cs-card__title">{l s='Assistance' d='Shop.Theme.Cshop'}</h2>
      {widget_block name='ps_contactinfo'}
        <ul class="cs-support__list">
          {if !empty($contact_infos.phone)}
            <li><span class="material-icons" aria-hidden="true">&#xE0CD;</span> <a href="tel:{$contact_infos.phone|replace:' ':''}">{$contact_infos.phone}</a></li>
          {/if}
          {if !empty($contact_infos.email) && $display_email}
            <li><span class="material-icons" aria-hidden="true">&#xE0BE;</span> <a href="mailto:{$contact_infos.email}">{$contact_infos.email}</a></li>
          {/if}
        </ul>
      {/widget_block}
      <a class="btn btn-outline-primary" href="{$urls.pages.contact}">{l s='Contact us' d='Shop.Theme.Global'}</a>
    </div>

    <div class="cs-support__delivery">
      {widget name='blockreassurance'}
    </div>
  </div>
</section>
