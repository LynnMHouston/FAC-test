// Awards
local base = import 'Base.schema.libsonnet';

// Repetative bits
local meta_rc = { row: 'integer', column: 'integer' };

local Awards = {
  '$schema': 'https://json-schema.org/draft/2019-09/schema#',
  additionalProperties: true,
  metamodel_version: '1.7.0',
  properties: {
    FederalAwards: {
      '$ref': '#/properties/Awards',
    },
    Awards: {
      type: 'array',
      items: {
        '$ref': '#/properties/Award',
      },
      minItems: 1,
    },
    Award: {
      type: 'object',
      properties: {
        meta: meta_rc,
        federal_agency_prefix: {
          '$ref': 'Common.schema.json#/$defs/FederalAgencyPrefix',
        },
        aln_extension: {
          '$ref': 'Common.schema.json#/$defs/ALNExtension',
        },
        federal_program_name: {
          //  FIXME: What is the max length?,
          type: 'string',
          minLength: 3,
          maxLength: 255,
        },
        amount_expended: {
          type: 'number',
          minimum: 0,
        },
      },
      required: [
        'federal_agency_prefix',
        'aln_extension',
        'federal_program_name',
      ],
    },

  },
  required: [
    'Awards',
  ],
  title: 'awards',
  type: 'object',
  version: null,
  "$local": {
    A: "B"
  },
};

base.Base + Awards
