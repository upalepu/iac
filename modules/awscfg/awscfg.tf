
# Overrides defaults if provided by caller
locals { _cfg = "${merge(var.def_cfg,var.cfg)}" }
# Map argument for AWS Configuration Data. Supplied by caller. 
variable "cfg" { 
    description = "AWS Configuration Data"
    type = "map" 
}
# Default AWS Configuration data (profile, cli output, region, ide, secret etc.)
variable "def_cfg" {
    type = "map"
    description = <<DESCRIPTION
This is the default configuration for the AWS cli on the local machine. 
Note that user, id & secret do not have defaults and will need to be 
supplied by the caller. Region is another value the caller can supply if 
necessary. The other data like the location, file names etc are not likely to 
change and will use the defaults below. If necessary, the caller can always 
supply different values. Also, the user name and profile are also empty and 
need to be supplied by the caller.    
DESCRIPTION
    default = {
        user = ""
        profile = ""
        region = "us-east-1"
        output = "json"
        id = ""
        secret = ""
        awscfgdir = "$HOME/.aws"
        cfgfile = "config"
        credfile = "credentials"
        workingdir = "."
    }
}

locals {
    _cfgfile = "${local._cfg["awscfgdir"]}/${local._cfg["cfgfile"]}"
    _credfile = "${local._cfg["awscfgdir"]}/${local._cfg["credfile"]}"
    _tcfg = "${local._cfgfile}.tmp"
    _tcred = "${local._credfile}.tmp"
    # user profile needs the word "profile " prefixed before the user name in the config file  
    _cfgsection = "${local._cfg["profile"] == "default" ? "${local._cfg["profile"]}" : "profile ${local._cfg["user"]}" }"
    # No tweak needed for section name in the credential file  
    _credsection = "${local._cfg["user"]}"
}
resource "null_resource" "awscfg" {
    triggers {
        aws_user = "${local._cfg["user"]}"
        aws_profile = "${local._cfg["profile"]}"
    }
    
    # Using heredoc syntax for running the command "cmd" and also for simulating user input.
    # The outer heredoc(CMD) is to allow the "command" argument be split across multiple lines
    # The inner heredoc (PROMPTS) simulates the user inputs via variables.
    # If "user" is not specified, then exit with error. terraform apply will fail.      
    provisioner "local-exec" {
        when = "create"
        command = <<CMD
if [[ "${local._cfg["user"]}" == "" || "${local._cfg["profile"]}" == "" ]]; then exit 1; fi
if [[ "${local._cfg["profile"]}" == "default" ]]; then
    cmd="aws configure"
else
    cmd="aws configure --${local._cfgsection}"
fi 
$cmd <<PROMPTS 
${local._cfg["id"]}
${local._cfg["secret"]}
${local._cfg["region"]}
${local._cfg["output"]}
PROMPTS
CMD
        working_dir = "${local._cfg["workingdir"]}"
        interpreter = [ "/bin/bash", "-c" ] 
    }

    # Removes the section added to the config and credentials files in AWS. 
    provisioner "local-exec" {
        when = "destroy"
        command = <<CMD
cat "${local._cfgfile}" | tr '\n' '\f' | sed -n 's/\[${local._cfgsection}[^\[]\+\([\[\f]\)\(.*\)/\1\2/p' | tr '\f' '\n' > "${local._tcfg}"
rm "${local._cfgfile}"; mv "${local._tcfg}" "${local._cfgfile}"   
cat "${local._credfile}" | tr '\n' '\f' | sed -n 's/\[${local._credsection}[^\[]\+\([\[\f]\)\(.*\)/\1\2/p' | tr '\f' '\n' > "${local._tcred}"
rm "${local._credfile}"; mv "${local._tcred}" "${local._credfile}"   
CMD
        working_dir = "${local._cfg["workingdir"]}"
        interpreter = [ "/bin/bash", "-c" ]
    }
}
