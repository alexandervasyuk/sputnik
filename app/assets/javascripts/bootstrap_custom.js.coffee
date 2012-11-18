$('.dropdown-menu').on('touchstart.dropdown.data-api', (e) ->
    e.stopPropagation() )