# No automatic unlock possible for now
# Mount SDCard
bcachefs unlock -k session /dev/disk/by-uuid/c22a37a0-2ce9-4447-a1e5-e1a501a4ae1a
mount /dev/disk/by-uuid/c22a37a0-2ce9-4447-a1e5-e1a501a4ae1a /SDMedia
# Mount External Drive
bcachefs unlock -k session /dev/disk/by-uuid/97c07ac6-f5d8-4ab2-8f8f-3b089416d8ed
mount /dev/disk/by-uuid/97c07ac6-f5d8-4ab2-8f8f-3b089416d8ed /LargeMedia
