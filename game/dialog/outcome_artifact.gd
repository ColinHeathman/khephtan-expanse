class_name OutcomeActionArtifact
extends OutcomeAction

@export var artifact: ArtifactKind

enum ArtifactKind {
	CIVIC_CROWN,
	SCIMITAR,
	LANTERN,
	SPYGLASS,
	SCEPTER,
	SCARABKEY,
}

func exec(_menu: Node) -> bool:
	var artifacts_service = _menu.get_node("/root/ArtifactsService")
	var cb = {
		ArtifactKind.CIVIC_CROWN: func(): artifacts_service.has_civic_crown = true,
		ArtifactKind.SCIMITAR: func(): artifacts_service.has_scimitar = true,
		ArtifactKind.LANTERN: func(): artifacts_service.has_lantern = true,
		ArtifactKind.SPYGLASS: func(): artifacts_service.has_spyglass = true,
		ArtifactKind.SCEPTER: func(): artifacts_service.has_scepter = true,
		ArtifactKind.SCARABKEY: func(): artifacts_service.has_scarab_key = true,
	}
	cb[artifact].call()
	return true
