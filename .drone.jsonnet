local submodules = {
    name: 'submodules',
    image: 'drone/git',
    commands: ['git fetch --tags', 'git submodule update --init --recursive --depth=1']
};

local flutter_builder(name, image, target, build_type, extra_cmds=[], allow_fail=false) = {
    kind: 'pipeline',
    type: 'docker',
    name: name,
    platform: {arch: "amd64"},
    trigger: { branch: { exclude: ['debian/*', 'ubuntu/*'] } },
    steps: [
        submodules,
        {
            name: 'build',
            image: image,
            [if allow_fail then "failure"]: "ignore",
            environment: { SSH_KEY: { from_secret: "SSH_KEY" }, ANDROID: "android" },
            commands: [
                'flutter build ' + target + ' --' + build_type
            ] + extra_cmds
        }
    ]
};
[
  flutter_builder("android debug", "registry.oxen.rocks/lokinet-ci-android", "apk", "debug", extra_cmds=['UPLOAD_OS=android ./contrib/ci/drone-static-upload.sh']),
  #flutter_builder("android release", "registry.oxen.rocks/lokinet-ci-android", "apk", "release", extra_cmds=['UPLOAD_OS=android ./contrib/ci/drone-static-upload.sh']),
]
