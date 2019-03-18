$(function() {
    window.PushPipe = function(event, data) {
        const pipe = {
            __event: event,
            __data: data
        }

        $.post("http://nuipipe/__piperesponse", JSON.stringify(pipe))
    }

    window.addEventListener('message', (event) => {
        if(event.data.action == "open") {
            $('#section').css("visibility", "visible")
        }
    })
    
    $('#exit-button').click(function() {
        PushPipe("ATM:Close", {})

        $('#section').css("visibility", "hidden")
    })

    $('#deposit-button').click(function() {
        var amount = $('#amount-form').val()

        if(amount != null) {    
            $('#amount-form').val("")

            PushPipe("ATM:Deposit", amount)
        }
    })

    $('#withdraw-button').click(function() {
        var amount = $('#amount-form').val()

        if(amount != null) { 
            $('#amount-form').val("")

            PushPipe("ATM:Withdrawal", amount)
        }
    })
})