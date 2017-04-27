import QtQuick 2.8

Rectangle
{
    id: rect
    width: 80
    height: width
    radius: width * .5
    smooth: true
    property int duration:1250
    property int bottomValue:500
    property int topValue:20
    function startTop(){
        rect.y = rect.topValue;
        moveBottom.start();
    }
    function startBottom(){
        rect.y = rect.bottomValue;
        moveTop.start();
    }
    function stop(){
        moveBottom.stop()
        moveTop.stop()
    }

    gradient: Gradient
    {
        GradientStop { position: 0.0; color: "#AA000000" }
        GradientStop { position: 1.0; color: "#11000000" }
    }

    SequentialAnimation
    {
        id:moveBottom
        running: true
        loops:1
        alwaysRunToEnd: true
        onStarted: {
            rect.visible = true;
        }

        NumberAnimation
        {
            id:downAnimation
            target:rect
            property: "y"
            duration: rect.duration
            from:topValue
            to:bottomValue
        }
        onStopped: {
            moveTop.start()
        }
    }
    SequentialAnimation
    {
        id:moveTop
        running: true
        alwaysRunToEnd: true
        loops:1
        onStarted: {
            rect.visible = true;
        }
        NumberAnimation
        {
            id:topAnimation
            target:rect
            property: "y"
            duration: rect.duration
            from:bottomValue
            to:topValue
        }
        onStopped: moveBottom.start();
    }
}
