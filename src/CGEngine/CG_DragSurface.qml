import QtQuick 2.8

MouseArea{
    property bool  holdingValidClick:false
    property int   clickIndex:-1
    property int   dragIndex:-1
    property int   hoverIndex:-1
    property real  cellSize:0
    property int   rowCount:0
    signal  clickStarted(int index)
    signal  clickMoved(int start, int end)
    signal  dragStarted(int index)
    signal  dragMoved(int start,int end)
    signal  dragStartHover(int start)
    signal  dragStoppedHover(int left)
    signal  pressedAt(int index)
    z:100
    drag.smoothed:true
    drag.threshold: .1
    function getIndex(x,y){
        var col = parseInt(x/cellSize);
        var row = parseInt(y/cellSize);
        return (row*rowCount) + col;
    }
    function setSelected(index, selected){
        clickIndex = index;
        holdingValidClick = selected;
    }
    hoverEnabled: true

    onClicked: {
        if(holdingValidClick){
            clickMoved(clickIndex, getIndex(mouse.x,mouse.y))
        }
        else{
            clickStarted(getIndex(mouse.x,mouse.y));
        }
    }
    onPressed: {
        dragIndex = getIndex(mouse.x,mouse.y);
        pressedAt(dragIndex);
        hoverIndex = dragIndex;
    }
    onPositionChanged: {
        if(drag.active){
            if(hoverIndex === -1){
                hoverIndex = getIndex(mouse.x,mouse.y);
                dragStartHover(hoverIndex);
            }
            else{
                dragStoppedHover(hoverIndex);
                hoverIndex = getIndex(mouse.x,mouse.y);
                dragStartHover(hoverIndex);
            }
        }
    }

    onReleased: {
        if(drag.active)
        {
            var dropIndex = getIndex(mouse.x,mouse.y);
            dragMoved(dragIndex,dropIndex);
            dragIndex = -1;
            drag.targt = null;
            dragStoppedHover(dropIndex);
            hoverIndex = -1;
        }
    }

}

