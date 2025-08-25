<?php
/************************************************************************
 * Custom Footer View
 * This customization removes the EspoCRM watermark and allows custom branding
 ************************************************************************/

namespace Espo\Custom\Resources\views\Site;

class Footer
{
    public static function getTemplate()
    {
        return 'custom:site/footer';
    }
}