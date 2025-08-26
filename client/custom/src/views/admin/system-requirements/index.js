define('custom:views/admin/system-requirements/index', 'views/admin/system-requirements/index', function (Dep) {

    return Dep.extend({

        afterRender: function () {
            Dep.prototype.afterRender.call(this);
            
            // Remove all espocrm.com links
            this.$el.find('a[href*="espocrm.com"]').remove();
            this.$el.find('a[href*="docs.espocrm.com"]').remove();
            
            // Remove any text containing espocrm.com
            this.$el.find('*').contents().filter(function() {
                return this.nodeType === 3 && this.textContent.includes('espocrm.com');
            }).remove();
        }
    });
});