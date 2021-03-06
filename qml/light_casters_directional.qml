import QtQuick 2.7

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.0

import VirtualKey 1.0

import "Components"

Scene2 {
	id: scene
	children: VirtualKeys {
		target: scene
		gameButtonsEnabled: false
		color: "transparent"
		centerItem: RowKeys {
			keys: [
				{text:"Space", key:Qt.Key_Space},
			]
		}
	}

	Entity {
		id: root

		RenderInputSettings0 {
			id: renderInputSettings

			mouseSensitivity: .5 / Units.dp
		}

		KeyboardDevice {
			id: keyboardDevice
		}

		KeyboardHandler {
			id: keyboardHandler
			sourceDevice: keyboardDevice
			focus: true

			onSpacePressed: {
				root.useQtLight = !root.useQtLight;
				console.log("useQtLight:", root.useQtLight);
			}
		}

		property bool useQtLight: false

		property var cubePositions: [
			Qt.vector3d( 0.0,  0.0,  0.0),
			Qt.vector3d( 2.0,  5.0, -15.0),
			Qt.vector3d(-1.5, -2.2, -2.5),
			Qt.vector3d(-3.8, -2.0, -12.3),
			Qt.vector3d( 2.4, -0.4, -3.5),
			Qt.vector3d(-1.7,  3.0, -7.5),
			Qt.vector3d( 1.3, -2.0, -2.5),
			Qt.vector3d( 1.5,  2.0, -2.5),
			Qt.vector3d( 1.5,  0.2, -1.5),
			Qt.vector3d(-1.3,  1.0, -1.5),
		]
		property vector3d viewPos: renderInputSettings.camera.position
		property color lightColor: "white"
		property Entity material: Entity {
			property Texture2D diffuseMap: Texture2D {
				TextureImage {
					source: Resources.texture("container2.png")
				}
			}

			property Texture2D specularMap: Texture2D {
				TextureImage {
					source: Resources.texture("container2_specular.png")
				}
			}

			property real shininess: 32.
		}

		QtObject {
			id: light

			property vector3d direction: "-0.2, -1.0, -0.3"

			property vector3d ambient: "0.2, 0.2, 0.2"
			property vector3d diffuse: "0.5, 0.5, 0.5"
			property vector3d specular: "1.0, 1.0, 1.0"
		}

		CuboidMesh {
			id: mesh
		}

		Material {
			id: ourMaterial
			effect: Effect {
				techniques: Technique {
					renderPasses: RenderPass {
						shaderProgram: ShaderProgram0 {
							vertName: "lighting_maps"
							fragName: "light_casters_directional"
						}
						parameters: [
							Parameter {
								name: "viewPos"
								value: root.viewPos
							},
							Parameter {
								name: "material.diffuse"
								value: root.material.diffuseMap
							},
							Parameter {
								name: "material.specular"
								value: root.material.specularMap
							},
							Parameter {
								name: "material.shininess"
								value: root.material.shininess
							},
							Parameter {
								name: "light.direction"
								value: light.direction
							},
							Parameter {
								name: "light.ambient"
								value: light.ambient
							},
							Parameter {
								name: "light.diffuse"
								value: light.diffuse
							},
							Parameter {
								name: "light.specular"
								value: light.specular
							}
						]
					}
				}
			}
		}

		DiffuseSpecularMapMaterial {
			id: qtMaterial
			ambient: Qt.rgba(light.ambient.x, light.ambient.y, light.ambient.z, 1.) // ...
			diffuse: Resources.texture("container2.png")
			specular: Resources.texture("container2_specular.png")
			//diffuse: root.material.diffuseMap   // FIXME: Qt5.9 ???
			//specular: root.material.specularMap // FIXME: Qt5.9 ???
			shininess: root.material.shininess
		}

		NodeInstantiator {
			model: root.cubePositions
			delegate: Entity {
				property Transform transform: Transform {
					translation: modelData
					rotation: fromAxisAndAngle(Qt.vector3d(0.5, 1.0, 0.0), 20 * index)
				}
				components: [mesh, root.useQtLight?qtMaterial:ourMaterial, transform]
			}
		}

		Entity {
			id: sun

			DirectionalLight {
				id: qtLight
				color: root.lightColor
				worldDirection: light.direction
			}

			components: [qtLight]
		}
	}
}
