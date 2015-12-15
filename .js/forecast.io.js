$(function() {

    var $levels = $('ul.levels');

    var clickLocal = function() {

        // Wait until there's already a selected level.
        if ($('li.selected', $levels).length) {
            setTimeout(function() {

                // Switch to the local view.
                $('li', $levels).get(0).click();

                // Click the map so we can auto-start animation.
                $('div.cities').click();

                // Trigger the mouseover so we can see the timeline.
                $('div.controls').css('opacity', 1);

            }, 0);
        } else {
            setTimeout(function() { clickLocal(); }, 1000);
        }
    };

    clickLocal();

});
