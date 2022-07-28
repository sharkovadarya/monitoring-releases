// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "jquery";

$(document).on('turbo:load', function(){
    console.log("Hello World!");

    const releaseNotesReadmore = $('.release-notes__readmore');

    releaseNotesReadmore.click(function() {
        console.log("clicked!")
        const releaseNotes = $(this).closest('div[class=release-notes__container]').children('.release-notes__content:first');
        if (releaseNotes.prop('cell_expanded') === true) {
            releaseNotes.animate({height: releaseNotes.prop('old_height')}, 500);
            releaseNotes.prop('cell_expanded', false);
            $(this).children().eq(0).text('Expand')
        } else {
            const reducedHeight = releaseNotes.height();
            releaseNotes.css('height', 'auto');
            const fullHeight = releaseNotes.height();
            const fontSize = releaseNotes.css('font-size');
            const lineHeight = Math.floor(parseInt(fontSize.replace('px', '')) * 1.5);
            releaseNotes.height(reducedHeight);
            releaseNotes.animate({height: fullHeight + lineHeight}, 500);
            releaseNotes.prop('old_height', reducedHeight);
            releaseNotes.prop('cell_expanded', true);
            $(this).children().eq(0).text('Collapse')
        }
    });

    releaseNotesReadmore.each(function(  ) {
        const releaseNotesContent = $(this).closest('div[class=release-notes__container]')
            .children('.release-notes__content:first')
        const releaseNotesContentHeight = releaseNotesContent.height()
        releaseNotesContent.css('height', 'auto');
        const fullHeight = releaseNotesContent.height();
        releaseNotesContent.css('height', releaseNotesContentHeight)
        console.log(fullHeight)
        $(this).toggle(fullHeight >= 200);
    });
});

