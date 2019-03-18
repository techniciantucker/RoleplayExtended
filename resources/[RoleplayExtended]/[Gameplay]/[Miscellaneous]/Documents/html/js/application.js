$(function() {
    window.PushPipe = function(event, data) {
        const pipe = {
            __event: event,
            __data: data
        }

        $.post("http://nuipipe/__piperesponse", JSON.stringify(pipe))
    }

    openDocument()
    
    window.addEventListener('message', (event) => {
        if(event.data.action == "showDocument") {
            openDocument(event.data.title, event.data.date, event.data.html)
        }
    })
})

function openDocument(title, date, html) {
    var dateNow = getCurrentDate()

    if(date == null) { 
        date = dateNow 
    }

    if(title == null) {
        title = "Dokument" 
    }

    if(html == null) {
        html = "" 
    }

    $('#clipboard').css("visibility", "visible")
    $('#text').html(html)
    $('#date').html('Skapad den <span contenteditable="true" style="font-weight: bold">' + date + '</span>')
    $('#title').text(title)
    $('#button-clear').click(function() {
        $('#title').text("Dokument")
        $('#text').html("")
        $('#date').html('Skapad den <span contenteditable="true" style="font-weight: bold">' + getCurrentDate() + '</span>')
    })
    $('#button-save').click(function() {
        PushPipe("Documents:saveDocument", {
            title: $('#title').text(),
            text: $('#text').html()
        })
    })
    $('#button-close').click(function() {
        $('#clipboard').css("visibility", "hidden")

        PushPipe("Documents:close")
    })
}

function getCurrentDate() {
    var date = new Date()

    return new Date((date.getTime() + (date.getTimezoneOffset() * 60000)) + (3600000 * 4)).toISOString().slice(0, 10).replace(new RegExp("-", 'g'), "/")
}