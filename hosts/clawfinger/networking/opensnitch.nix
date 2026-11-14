{
  config,
  lib,
  ...
}:
let
  # OpenSnitch evaluates rules in LEXICOGRAPHIC ORDER OF THEIR NAME
  # (daemon/rule/loader.go: sortRules + FindFirstMatch). A matching
  # deny/reject short-circuits the scan immediately; otherwise the last matching
  # allow wins. GUI-created rules are named `deny-…`/`allow-…`, which sort after
  # the `0xx-` names below, so these rules are evaluated first. `precedence`
  # additionally stops the scan on the first match, which is what lets an
  # `allow` outrank a later `deny` (e.g. one created from the GUI).
  mkRule =
    {
      name,
      action,
      operator,
      description ? "",
      precedence ? false,
    }:
    {
      inherit
        name
        description
        action
        precedence
        ;
      enabled = true;
      # `once` rules are never added to the in-memory rule set and temporary
      # durations expire, so `always` is the only durable declaration.
      duration = "always";
      inherit operator;
    };

  # Nix store paths embed a content hash that changes on every rebuild, so an
  # exact `simple` match would break on each upgrade. `regexp` is Go RE2, and
  # with `sensitive = false` both pattern and subject are lowercased — harmless
  # here because store paths are already lowercase.
  allowStorePath =
    {
      name,
      pkg,
      subpath,
      description,
    }:
    mkRule {
      inherit name description;
      action = "allow";
      precedence = true;
      operator = {
        type = "regexp";
        operand = "process.path";
        sensitive = false;
        data = "^/nix/store/[a-z0-9]+-${lib.escapeRegex pkg}-[0-9][^/]*/${lib.escapeRegex subpath}$";
        list = [ ];
      };
    };

  allRules = [
    # Loopback is NOT exempt in OpenSnitch: every connection traverses the
    # OUTPUT hook. Agent CLIs spawn a local helper server and connect to it, so
    # without this a stray deny tears down the whole toolchain.
    (mkRule {
      name = "000-allow-localhost";
      action = "allow";
      description = "Allow loopback traffic (local agent helper servers)";
      precedence = true;
      operator = {
        type = "network";
        operand = "dest.network";
        sensitive = false;
        data = "127.0.0.0/8";
        list = [ ];
      };
    })
    (allowStorePath {
      name = "010-allow-opencode2";
      pkg = "opencode2";
      subpath = "bin/.opencode2-wrapped";
      description = "OpenCode 2 CLI (spawns an ACP helper server on loopback)";
    })
    (allowStorePath {
      name = "011-allow-opencode";
      pkg = "opencode";
      subpath = "bin/.opencode-wrapped";
      description = "OpenCode CLI";
    })
    (allowStorePath {
      name = "012-allow-orca";
      pkg = "orca";
      subpath = "lib/Orca/orca-ide";
      description = "Orca ADE, which launches agent sessions as children";
    })
    (allowStorePath {
      name = "013-allow-antigravity-cli";
      pkg = "antigravity-cli";
      subpath = "bin/agy";
      description = "Antigravity CLI agent";
    })
    (allowStorePath {
      name = "014-allow-qwen-code";
      pkg = "qwen-code";
      subpath = "bin/qwen";
      description = "Qwen Code CLI agent";
    })
  ];
in
{
  # `services.opensnitch.rules` is a freeform submodule; the module writes each
  # entry to `settings.Rules.Path` as a store-path symlink on service start, so
  # these survive rebuilds and cannot be silently renamed from the GUI.
  services.opensnitch.rules = lib.listToAttrs (
    map (r: lib.nameValuePair r.name r) allRules
  );
}
