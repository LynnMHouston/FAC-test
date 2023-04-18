local Base = import 'Base.libsonnet';
local Func = import 'Functions.libsonnet';
local Types = Base.Types;

local Validations = {
  
  DirectAwardValidations: [
    {
      'if': {
        properties: {
          is_direct: {
            const: Base.Const.Y,
          },
        },
      },
      'then': {
        properties: {
          entities: Base.Enum.EmptyString_EmptyArray_Null,
        },
      },
    },
    {
      'if': {
        properties: {
          is_direct: {
            const: Base.Const.N,
          },
        },
      },
      'then': {
        required: [
          'entities',
        ],
      },
    },
      ],
  LoanOrLoanGuaranteeValidations: [
    {
      'if': {
        properties: {
          is_guaranteed: {
            const: Base.Const.Y,
          },
        },
      },
      'then': {
        properties: {
          // 20230409 MCJ
          // FIXME: If the answer is Y, why can the balance be N/A?
          loan_balance_at_audit_period_end: {
            anyOf: [
              Types.integer {
                minimum: 1,
              },
              Base.Enum.NA,
            ],
          },
        },
        required: ['loan_balance_at_audit_period_end'],
      },
    },
    {
      'if': {
        properties: {
          is_guaranteed: {
            const: Base.Const.N,
          },
        },
      },
      'then': {
        properties: {
          loan_balance_at_audit_period_end: Base.Enum.EmptyString_Zero_Null,
        },
      },
    },
  ],
  SubrecipientValidations: [
    {
      'if': {
        properties: {
          is_passed: {
            const: Base.Const.Y,
          },
        },
      },
      'then': {
        required: [
          'amount',
        ],
        properties: {
          amount: Types.integer,
        },
      },
    },
    {
      'if': {
        properties: {
          is_passed: {
            const: Base.Const.N,
          },
        },
      },
      'then': {
        properties: {
          amount: Base.Enum.EmptyString_Zero_Null,
        },
      },
    },
  ],
  ProgramValidations: [
    {
      'if': {
        properties: {
          is_major: {
            const: Base.Const.Y,
          },
        },
      },
      'then': {
        'if': {
          properties: {
            audit_report_type: {
              anyOf: [
                {
                  const: 'A',
                },
                {
                  const: 'Q',
                },
              ],
            },
          },
        },
        'then': {
          properties: {
            number_of_audit_findings: Types.integer {
              exclusiveMinimum: 0,
            },
          },
        },
        'else': {
          properties: {
            audit_report_type: Base.Enum.MajorProgramAuditReportType,
            number_of_audit_findings: Types.integer {
              // minimum: 0,
              // maximum: 0,
              const: 0,
            },
          },
        },
      },
    },
    {
      // 20230409 MCJ FIXME: Should we require all fields always,
      // and make sure thet ype checking is correct in each conditional branch?
      // FIXME: Should we ALWAYS require a value in EVERY field, and disallow
      // the empty/null responses everywhere?
      'if': {
        properties: {
          is_major: {
            const: Base.Const.N,
          },
        },
      },
      'then': {
        properties: {
          audit_report_type: Base.Enum.EmptyString_Null,
          number_of_audit_findings: { const: 0 },
        },

      },
    },
  ] 
};

local Parts = {
  Cluster: Types.object {
    properties: {
      name: Base.Compound.ClusterName,
      total: Types.number,
    },
    allOf: [
      {
        "if": {
          "not": {
            properties: {
                name: {
                  enum: [Base.Const.OTHER_CLUSTER,Base.Const.STATE_CLUSTER]
              },                                   
            },
          }
        },
        "then": {
          "allOf": [
            {
                properties: {
                  other_cluster_name: Base.Enum.EmptyString_Null,
                },
              },
              {
                properties: {
                  state_cluster_name: Base.Enum.EmptyString_Null,
                },
              }
          ]
        },
      },        
      {
        "if": {
          properties: {
            name: {
              const: Base.Const.STATE_CLUSTER,
            },
           },
        },
        "then": {
          properties: {
            state_cluster_name: Base.Compound.NonEmptyString,
          },
          required: ['state_cluster_name'] 
        },
      },  
      {
        "if": {
          properties: {
            name: {
              const: Base.Const.OTHER_CLUSTER,
            },
          },
        },
        "then": {
          properties: {
            other_cluster_name: Base.Compound.NonEmptyString,
          },
          required: ['other_cluster_name'] 
        }
      },         
    ],    
    required: ['name']       
  },
  PassThroughEntity: Types.object {
    additionalProperties: false,
    properties: {
      name: Types.string,
      identifying_number: {
        type: 'string',
        minLength: 1,
      },
    },
    required: ['name', 'identifying_number']
  },
  DirectOrIndirectAward: Types.object {
    // 20230409 MCJ FIXME: I think this needs the amount...
    additionalProperties: false,
    description: 'If direct_award is N, the form must include a list of the pass-through entity by name and identifying number',
    properties: {
      is_direct: Base.Enum.YorN,
      entities: Types.array {
        items: Parts.PassThroughEntity,
      },
    },
    allOf: Validations.DirectAwardValidations,
  },
  LoanOrLoanGuarantee: Types.object {
    additionalProperties: false,
    description: 'A loan or loan guarantee and balance',
    properties: {
      is_guaranteed: Base.Enum.YorN,
      loan_balance_at_audit_period_end: Func.compound_type([Types.number, Types.string]),
    },
    required: [
      'is_guaranteed',
    ],
    allOf: Validations.LoanOrLoanGuaranteeValidations,
  },
  Subrecipients: Types.object {
    additionalProperties: false,
    properties: {
      is_passed: Base.Enum.YorN,
      amount: Func.compound_type([Types.number, Types.string]),
    },
    allOf: Validations.SubrecipientValidations,
  },
  Program: Types.object {
    additionalProperties: false,
    properties: {
      amount_expended: Types.number,
      name: Types.string,
      number: Base.Compound.ProgramNumber,
      is_major: Base.Enum.YorN,
      audit_report_type: Types.string,
      number_of_audit_findings: Types.integer,
    },
    required: ['name', 'number', 'is_major', 'audit_report_type', 'number_of_audit_findings'],
    allOf: Validations.ProgramValidations,
  },
};

local FederalAwardEntry = Types.object {
  additionalProperties: false,
  description: 'Award entry rows',
  properties: {
    amount_expended: Types.number {
      minimum: 0,
    },
    cluster: Parts.Cluster,
    direct_or_indirect_award: Parts.DirectOrIndirectAward,
    loan_or_loan_guarantee: Parts.LoanOrLoanGuarantee,
    program: Parts.Program,
    subrecipients: Parts.Subrecipients,
  },
  required: [
    'cluster',
    'direct_or_indirect_award',
    'loan_or_loan_guarantee',
    'program',
    'subrecipients',
  ],
  title: 'FederalAwardEntry',
};

local FederalAwards = Types.object {
  additionalProperties: false,
  properties: {
    auditee_ein: Func.compound_type([Types.string, Types.NULL]),
    federal_awards: Types.array {
      items: FederalAwardEntry,
    },
    total_amount_expended: Types.number {
      minimum: 0,
    },
  },
  required: ['auditee_ein', 'total_amount_expended'],
  title: 'FederalAward',
  version: 20230408,
};

local Root = Types.object {
  additionalProperties: false,
  properties: {
    FederalAwards: FederalAwards,
  },
  version: 20230408,
};

Base.SchemaBase + Root
