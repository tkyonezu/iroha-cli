from enum import Enum

from cli import crypto

from schema.commands_pb2 import Command, CreateAsset, AddAssetQuantity, CreateAccount
from schema.primitive_pb2 import Amount, uint256

BASE_NAME = "iroha-mizuki-cli"


class CommandList:
    """
            AddAssetQuantity add_asset_quantity = 1;
            AddPeer add_peer = 2;
            AddSignatory add_signatory = 3;
            CreateAsset create_asset = 4;
            CreateAccount create_account = 5;
            CreateDomain create_domain = 6;
            RemoveSignatory remove_sign = 7;
            SetAccountPermissions set_permission = 8;
            SetAccountQuorum set_quorum = 9;
            TransferAsset transfer_asset = 10;
            AppendRole append_role = 11;
            CreateRole create_role = 12;
            GrantPermission grant_permission = 13;
            RevokePermission revoke_permission = 14;
            ExternalGuardian external_guardian = 15;
    """

    class Type(Enum):
        STR = 1
        INT = 2
        UINT = 3
        FLOAT = 4

    def __init__(self, printInfo=False):
        self.printInfo = printInfo
        self.commands = {
            "config": {
                "option": {},
                "function": self.config,
                "detail": " Print current state \n"
                          "   - name\n"
                          "   - publicKey\n"
                          "   - privateKey\n"
            },
            "AddAssetQuantity": {
                "option": {
                    "account_id": {
                        "type": self.Type.STR,
                        "detail": "target's account id like mizuki@domain",
                        "required": True
                    },
                    "asset_id": {
                        "type": self.Type.STR,
                        "detail": "target's asset id like japan/yen",
                        "required": True
                    },
                    "amount": {
                        "type": self.Type.FLOAT,
                        "detail": "target's asset id like japan/yen",
                        "required": True
                    },
                },
                "function": self.AddAssetQuantity,
                "detail": "Add asset's quantity"
            },
            "CreateAccount": {
                "option": {
                    "account_name": {
                        "type": self.Type.STR,
                        "detail": "account name like mizuki",
                        "required": True
                    },
                    "domain_id": {
                        "type": self.Type.STR,
                        "detail": "new account will be in this domain like japan",
                        "required": True
                    },
                    "keypair_name": {
                        "type": self.Type.STR,
                        "detail": "save to this keypair_name like mizukey, if no set, generates ${"
                                  "account_name}.pub/${account_name} ",
                        "required": False
                    }
                },
                "function": self.CreateAccount,
                "detail": "CreateAccount asset's quantity"
            },
            "CreateDomain": {
                "option": {
                    "domain_name": {
                        "type": self.Type.STR,
                        "detail": "new domain name like japan",
                        "required": True
                    }
                },
                "function": self.CreateDomain,
                "detail": "Create domain in domain"
            },
            "CreateAsset": {
                "option": {
                    "asset_name": {
                        "type": self.Type.STR,
                        "detail": "asset name like mizuki",
                        "required": True
                    },
                    "domain_id": {
                        "type": self.Type.STR,
                        "detail": "new account will be in this domain like japan",
                        "required": True
                    },
                    "precision": {
                        "type": self.Type.STR,
                        "detail": "how much support .000, default 0",
                        "required": False
                    }
                },
                "function": self.CreateAsset,
                "detail": "Create new asset in domain"
            },
            "TransferAsset": {
                "option": {
                    "src_account_id": {
                        "type": self.Type.STR,
                        "detail": "current owner's account name like mizuki@japan",
                        "required": True
                    },
                    "dest_account_id": {
                        "type": self.Type.STR,
                        "detail": "next owner's account name like iori@japan",
                        "required": True
                    },
                    "asset_id": {
                        "type": self.Type.STR,
                        "detail": "managed asset's name like yen",
                        "required": True
                    },
                    "description": {
                        "type": self.Type.STR,
                        "detail": "attach some text",
                        "required": False
                    },
                    "amount": {
                        "type": self.Type.STR,
                        "detail": "how much transfer",
                        "required": True
                    }
                },
                "function": self.TransferAsset,
                "detail": "transfer asset"
            }
        }

    def validate(self, expected, argv):
        for item in expected.items():
            if item[1]["required"] and not item[0] in argv:
                raise Exception("{} is required".format(item[0]))
            if item[0] in argv:
                if item[1]["type"] == self.Type.STR and not isinstance(argv[item[0]], str):
                    raise Exception("{} is str".format(item[0]))

                if item[1]["type"] == self.Type.INT and not isinstance(argv[item[0]], int):
                    raise Exception("{} is integer".format(item[0]))
                if item[1]["type"] == self.Type.UINT and not isinstance(argv[item[0]], int) and argv[item[0]] < 0:
                    raise Exception("{} is unsigned integer".format(item[0]))
                if item[1]["type"] == self.Type.FLOAT and not isinstance(argv[item[0]], float):
                    raise Exception("{} is float".format(item[0]))

    def printTransaction(self, name, expected, argv):
        if self.printInfo:
            print("[{}] run {} ".format(BASE_NAME, name))
            for n in expected.keys():
                print("- {}: {}".format(n, argv[n]))

    def config(self, argv):
        print(
            "\n"
            "  Config  \n"
            " =========\n"
        )
        print(" name      : {}".format(self.name))
        print(" publicKey : {}".format(self.publicKey))
        print(" privateKey: {}".format(self.privateKey[:5] + "**...**" + self.privateKey[-5:]))
        print(" load from : {}".format(self.source))
        print("")
        return None

    def AddAssetQuantity(self, argv):
        name = "AddAssetQuantity"
        argv_info = self.commands[name]["option"]
        self.validate(argv_info, argv)
        self.printTransaction(name, argv_info, argv)

        # ToDo In now precision = 0, but when I enter 1.03, set precision = 2 automatically
        # ToDo Correct to set Amount.value
        return Command(add_asset_quantity=AddAssetQuantity(
            account_id=argv["account_id"],
            asset_id=argv["asset_id"],
            amount=Amount(value=uint256(
                first=int(argv["amount"]),
                second=0,
                third=0,
                fourth=0,
            ), precision=0)
        ))

    def CreateAccount(self, argv):
        name = "CreateAccount"
        argv_info = self.commands[name]["option"]
        self.validate(argv_info, argv)
        self.printTransaction(name, argv_info, argv)

        # ToDo validate and print check
        # I want to auto generate
        pubKey, priKey = crypto.generate_hex_sstr()
        filename_base = ""
        try:

            if "keypair_name" in argv:
                filename_base = argv["keypair_name"]
            else:
                filename_base = argv["account_name"] + "@" + argv["domain_id"]

            pub = open(filename_base + ".pub", "w")
            pub.write(pubKey)
            pri = open(filename_base, "w")
            pri.write(priKey)
            pub.close()
            pri.close()
        except Exception as e:
            print(e)
            print("file error")
            return None
        else:
            if self.printInfo:
                print(
                    "key save publicKey -> {} privateKey -> {}".format(filename_base + ".pub", filename_base))
                print("key save publicKey:{} privateKey:{}".format(
                    pubKey[:5] + "..." + pubKey[-5:],
                    priKey[:5] + "**...**" + priKey[-5:],
                ))
        return Command(create_account=CreateAccount(
            account_name=argv["account_name"],
            domain_id=argv["domain_id"],
            main_pubkey=pubKey.encode()
        ))

    def CreateAsset(self, argv):
        name = "CreateAsset"
        argv_info = self.commands[name]["option"]
        self.validate(argv_info, argv)
        self.printTransaction(name, argv_info, argv)

        return Command(create_asset=CreateAsset(
            asset_name=argv["asset_name"],
            domain_id=argv["domain_id"],
            precision=argv["precision"]
        ))

    def CreateDomain(self, argv):
        name = "CreateDomain"
        argv_info = self.commands[name]["option"]
        self.validate(argv_info, argv)
        self.printTransaction(name, argv_info, argv)
        return Command(create_domain=Command.CreateDomain(
            domain_name=argv["domain_name"]
        ))

    def TransferAsset(self, argv):
        name = "CreateDomain"
        argv_info = self.commands[name]["option"]
        self.validate(argv_info, argv)
        self.printTransaction(name, argv_info, argv)

        # ToDo validate and print check
        return Command(transfer_asset=Command.TransferAsset(
            src_account_id=argv["src_account_id"],
            dest_account_id=argv["dest_account_id"],
            asset_id=argv["asset_id"],
            description=argv.get("description", ""),
            amount=Amount(value=uint256(
                first=int(argv["amount"]),
                second=0,
                third=0,
                fourth=0,
            ), precision=0)
        ))