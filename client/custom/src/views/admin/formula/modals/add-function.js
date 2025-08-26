define('custom:views/admin/formula/modals/add-function', 'views/admin/formula/modals/add-function', function (Dep) {

    return Dep.extend({

        setup: function () {
            Dep.prototype.setup.call(this);
            
            // Remove documentation URL
            this.documentationUrl = null;
        },
        
        afterRender: function () {
            Dep.prototype.afterRender.call(this);
            
            // Remove documentation links
            this.$el.find('a[href*="espocrm.com"]').remove();
            this.$el.find('a[href*="docs.espocrm.com"]').remove();
        }
    });
});