$ ->
    $(".suite-template-autocomplete-field").each ->
        $field = $(this)

        $field.select2(
            minimumInputLength: 3,
            placeholder: $field.data("placeholder")
            ajax:
                url: $field.data("url")
                results: (data, page) ->
                    { results: data }
                data: (term, page) ->
                    { q: { name_cont: term }, page: page }
        )

    $("#new_suite #suite_is_template").on "change", ->
        if ($(this).is(":checked"))
            $("#new_participant").hide()
        else
            $("#new_participant").show()

    # Toggle between different values in the result table
    $(".suite-results .result-toggles").on "click", ".btn:not(.active)", ->
        $button = $(this)

        # Switch to the clicked button
        $button.addClass "active"
        $button.siblings().removeClass "active"

        # Change which value is displayed by replacing the CSS class
        $button.closest(".suite-results").attr "class", (i, cls) ->
            cls.replace /suite-show-\w+/, "suite-show-#{$button.data("value")}"
