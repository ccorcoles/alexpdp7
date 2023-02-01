#!/usr/bin/env python3

import json
import pathlib


def load_json(path):
    with open(path) as f:
        return json.load(f)

def save_json(r, path):
    with open(path, "w") as f:
        json.dump(r, f)

nagios_catalog_file = pathlib.Path("build/puppet/build/output/nagios.h1.int.pdp7.net/catalog.json")

if nagios_catalog_file.exists():
    nagios_catalog = load_json(nagios_catalog_file)

    nagios_contacts = [r for r in nagios_catalog["resources"] if r["type"] == "Nagios_contact"]
    assert len(nagios_contacts) == 1, f"found multiple nagios contacts {nagios_contacts}"
    nagios_contact = nagios_contacts[0]

total_hosts_in_inventory = len(list(pathlib.Path("host_vars").glob("*")))

catalog_files = list(pathlib.Path("build/puppet/build/output/").glob("*/catalog.json"))

if nagios_catalog_file.exists():
    assert len(catalog_files) == total_hosts_in_inventory, f"catalogs {catalog_files} quantity different from total hosts in inventory {total_hosts_in_inventory}"


nagios_resources = []
nagios_edge_targets = []

def is_nagios_resource(r):
    return r["type"].startswith("Nagios")


def is_nagios_edge(e):
    return e["target"].startswith("Nagios")

for catalog_file in catalog_files:
    if catalog_file == nagios_catalog_file:
        continue
    catalog = load_json(catalog_file)
    nagios_resources += [r for r in catalog["resources"] if is_nagios_resource(r)]
    catalog["resources"] = [r for r in catalog["resources"] if not is_nagios_resource(r)]
    nagios_edge_targets += [e["target"] for e in catalog["edges"] if is_nagios_edge(e)]
    catalog["edges"] = [e for e in catalog["edges"] if not is_nagios_edge(e)]
    save_json(catalog, catalog_file)
    

if nagios_catalog_file.exists():
    nagios_contact_position = nagios_catalog["resources"].index(nagios_contact)

    def copy_parameters(r):
        for p in ["require", "notify", "owner"]:
            r["parameters"][p] = nagios_contact["parameters"][p]
        return r

    nagios_catalog["resources"] = (
        nagios_catalog["resources"][0:nagios_contact_position] +
        list(map(copy_parameters, nagios_resources)) +
        nagios_catalog["resources"][nagios_contact_position:]
    )

    nagios_catalog["edges"] += [{"source": "Class[Nagios]", "target": t} for t in nagios_edge_targets]

    save_json(nagios_catalog, nagios_catalog_file)
