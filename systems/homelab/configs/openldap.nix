{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [389];
  services.openldap = {
    enable = true;
    mutableConfig = true;
    urlList = ["ldap:///"];
    settings = {
      attrs = {
        olcLogLevel = "conns config";
      };

      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
        ];
        #"cn=schema"."cn=config" = [
        #  "attributeType ( 3.0.0.1 NAME 'nextcloud-quota' DESC 'Quota in Nextcloud' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{10} )"
        #];

        "olcDatabase={1}mdb".attrs = {
          objectClass = ["olcDatabaseConfig" "olcMdbConfig"];

          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";

          olcSuffix = "dc=example,dc=com";

          /*
          your admin account, do not use writeText on a production system
          */
          olcRootDN = "cn=admin,dc=example,dc=com";
          olcRootPW.path = pkgs.writeText "olcRootPW" "pass";

          olcAccess = [
            /*
            custom access rules for userPassword attributes
            */
            ''              {0}to attrs=userPassword
                            by self write
                            by anonymous auth
                            by * none''

            /*
            allow read on anything else
            */
            ''              {1}to *
                            by * read''
          ];
        };
        "olcOverlay={2}ppolicy".attrs = {
          objectClass = ["olcOverlayConfig" "olcPPolicyConfig" "top"];
          olcOverlay = "{2}ppolicy";
          olcPPolicyHashCleartext = "TRUE";
        };

        "olcOverlay={3}memberof".attrs = {
          objectClass = ["olcOverlayConfig" "olcMemberOf" "top"];
          olcOverlay = "{3}memberof";
          olcMemberOfRefInt = "TRUE";
          olcMemberOfDangling = "ignore";
          olcMemberOfGroupOC = "groupOfNames";
          olcMemberOfMemberAD = "member";
          olcMemberOfMemberOfAD = "memberOf";
        };

        "olcOverlay={4}refint".attrs = {
          objectClass = ["olcOverlayConfig" "olcRefintConfig" "top"];
          olcOverlay = "{4}refint";
          olcRefintAttribute = "memberof member manager owner";
        };
      };
    };
  };
}
