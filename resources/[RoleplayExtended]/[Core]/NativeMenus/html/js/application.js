$(function() {
    window.PushPipe = function(event, data) {
        const pipe = {
            __event: event,
            __data: data
        }

        $.post("http://nuipipe/__piperesponse", JSON.stringify(pipe))
    }

    window.addEventListener('message', (event) => {
        if(event.data.action == "") {
            
        }
    })

    $('.menu-item').click(function() {
        $('#sub-menu').css("visibility", "visible")
        $('#sub-menu').animate({left: "30%"}, 500)
    })
})