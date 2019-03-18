$(function() {
    window.PushPipe = function(event, data) {
        const pipe = {
            __event: event,
            __data: data
        }

        $.post("http://nuipipe/__piperesponse", JSON.stringify(pipe))
    }

    window.addEventListener('message', (event) => {
        if(event.data.action == "createCorporation") {
            $('#contract').css("visibility", "visible")
        }
    })

    var canvas = document.getElementById("signature")
    var graphics = canvas.getContext("2d")
    var mouseDown = false
    var signature = $('#signature');
    var lastX = 0
    var lastY = 0

    $('#button-create').click(function() {
        PushPipe("Corporations:createCorporation", {
            name: $('#form-name').val(),
            description: $('#form-description').val(),
            startdeposit: $('#form-startdeposit').val(),
            signature: canvas.toDataURL()
        })
    })

    signature.mousedown(function(event) {
        mouseDown = true

        var rect = canvas.getBoundingClientRect()

        lastX = event.clientX - rect.left
        lastY = event.clientY - rect.top
    }).mouseup(function() {
        mouseDown = false
    }).mousemove(function(event) {
        if(mouseDown) {
            var rect = canvas.getBoundingClientRect()
            var x = event.clientX - rect.left
            var y = event.clientY - rect.top

            graphics.beginPath()
            graphics.strokeStyle = "#455A64"
            graphics.lineWidth = 5
            graphics.lineJoin = "round"
            graphics.moveTo(lastX, lastY)
            graphics.lineTo(x, y)
            graphics.closePath()
            graphics.stroke()

            lastX = x
            lastY = y
        } 
    })
})