import QtQuick 2.8
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
TextField {
    id:input
    placeholderText: ""
    // For testing purposes I inputted StarWars automatically
    text: ""
    font.pixelSize:height * .32
    style: TextFieldStyle {
        background: Rectangle {
            color: "#e7e9e8"
            smooth: true
            radius: 8
        }
    }
}


