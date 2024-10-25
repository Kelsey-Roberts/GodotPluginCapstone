@tool
extends Node3D  # or the appropriate node type

func nope() -> void:
	# Create the cylinder in the 3D scene
	var cylinder = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()  # Create a cylinder mesh
	cylinder_mesh.bottom_radius = 1.0  # Set the radius of the cylinder
	cylinder_mesh.height = 2.0  # Set the height of the cylinder
	cylinder.mesh = cylinder_mesh

	# Position the cylinder
	 # Adjust position as needed

	# Add the cylinder to this scene without setting owner
	add_child(cylinder)  # Add the cylinder to the node tree
	cylinder.owner = self.get_parent()
	
