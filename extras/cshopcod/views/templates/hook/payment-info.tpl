<section class="cshopcod-info">
  <p>{l s='You pay the courier when the parcel is delivered.' d='Modules.Cshopcod.Shop'}</p>
  <p>
    {l s='Cash on delivery surcharge: %fee%, added to the order as its own line.' sprintf=['%fee%' => $cshopcod_fee] d='Modules.Cshopcod.Shop'}
  </p>
  <p><strong>{l s='Total to pay on delivery: %total%' sprintf=['%total%' => $cshopcod_total] d='Modules.Cshopcod.Shop'}</strong></p>
</section>
