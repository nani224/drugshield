export type DrugCategory = 'Cocaine' | 'Meth' | 'Heroin' | 'Cannabis' | 'Synthetic';

export type SeizureStatus = 'ON-CHAIN' | 'IN-TRANSIT' | 'CFSL-VERIFIED' | 'TAMPER-ALERT';

export interface SeizureRecord {
  id: string;
  firNumber: string;
  officerId: string;
  officerName: string;
  substance: string;
  category: DrugCategory;
  confidence: number;
  weightGrams: number;
  location: string;
  coordinates: {
    lat: number;
    lng: number;
  };
  timestamp: string;
  status: SeizureStatus;
  sha256Hash: string;
  fabricTxId: string;
  blockNumber: number;
  reagentUsed: string;
  witnessCount: number;
  gazettedOfficerPresent: boolean;
  colorimetricHex: string;
}

export interface HotspotNode {
  id: string;
  name: string;
  state: string;
  coordinates: {
    lat: number;
    lng: number;
  };
  dominantSubstance: DrugCategory;
  seizureCount30d: number;
  totalWeightKg: number;
  riskLevel: 'CRITICAL' | 'HIGH' | 'MODERATE';
}

export interface CorridorVector {
  id: string;
  name: string;
  origin: string;
  destination: string;
  originCoords: [number, number]; // [lat, lng]
  destCoords: [number, number];   // [lat, lng]
  volumeKgPerMonth: number;
  interdictionRate: number;
}
