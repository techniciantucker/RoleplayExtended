(() => {
    window.PushPipe = function(event, data) {
        const pipe = {
            __event: event,
            __data: data
        }

        $.post("http://nuipipe/__piperesponse", JSON.stringify(pipe))
    }
})()