pragma ComponentBehavior: Bound

import qs.components
import qs.components.images
import qs.components.filedialog
import qs.services
import qs.config
import qs.utils
import QtQuick

Item {
    id: root

    property string source: Wallpapers.current
    property Item current: one

    onSourceChanged: {
        if (!source)
            current = null;
        else if (current === one)
            two.update();
        else
            one.update();
    }

    Component.onCompleted: {
        if (source)
            Qt.callLater(() => one.update());
    }

    Loader {
        anchors.fill: parent

        active: !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Appearance.spacing.large

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.extraLarge * 5
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.extraLarge * 2
                        font.bold: true
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Appearance.padding.large * 2
                        implicitHeight: selectWallText.implicitHeight + Appearance.padding.small * 2

                        radius: Appearance.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: qsTr("Select a wallpaper")
                            filterLabel: qsTr("Image files")
                            filters: Images.validImageExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path)
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary

                            function onClicked(): void {
                                dialog.open();
                            }
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: qsTr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font.pointSize: Appearance.font.size.large
                        }
                    }
                }
            }
        }
    }

    readonly property bool isGif: root.source.toString().toLowerCase().endsWith(".gif")

    Img {
        id: one
    }

    Img {
        id: two
    }

    component Img: Item {
        id: img

        property bool isGif: root.source.toLowerCase().endsWith(".gif")

        function update(): void {
            if (loader.item && loader.item.source === root.source)
                root.current = this;
            else
                loader.item.source = root.source;
        }

        anchors.fill: parent

        opacity: 0
        scale: Wallpapers.showPreview ? 1 : 0.8

        Loader {
            id: loader
            anchors.fill: parent

            sourceComponent: img.isGif ? gifComponent : imageComponent

            onLoaded: {
                item.source = root.source;
            }
        }

        Component {
            id: imageComponent
            CachingImage {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop

                onStatusChanged: {
                    if (status === Image.Ready)
                        root.current = img;
                }
            }
        }

        Component {
            id: gifComponent
            AnimatedImage {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                playing: true

                onStatusChanged: {
                    if (status === Image.Ready)
                        root.current = img;
                }
            }
        }

        states: State {
            name: "visible"
            when: root.current === img

            PropertyChanges {
                img.opacity: 1
                img.scale: 1
            }
        }

        transitions: Transition {
            Anim {
                target: img
                properties: "opacity,scale"
            }
        }
    }
}
