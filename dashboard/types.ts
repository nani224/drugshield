export type DrugCategory = "Cocaine" | "Meth" | "Heroin" | "Cannabis" | "Synthetic";

export type SeizureStatus = "ON-CHAIN" | "IN-TRANSIT" | "CFSL-VERIFIED" | "TAMPER-ALERT";

export interface ArucoCalibration {
  markerId: number;
  homographyRms: number;
  focalLengthPx: number;
  principalPoint: [number, number];
}

export interface CieLab {
  L: number;
  a: number;
  b: number;
}

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
  city: string;
  checkpost: string;
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
  bodySearchMemoSigned: boolean;
  reagentPhotoRecorded: boolean;
  colorimetricHex: string;
  streetValueInrLakhs: number;
  aruco: ArucoCalibration;
  cieLab: CieLab;
  endorsements: string[];
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
  riskLevel: "CRITICAL" | "HIGH" | "MODERATE";
}

export interface CorridorVector {
  id: string;
  name: string;
  origin: string;
  destination: string;
  originCoords: [number, number];
  destCoords: [number, number];
  volumeKgPerMonth: number;
  interdictionRate: number;
  riskLevel: "CRITICAL" | "HIGH" | "MODERATE";
  checkposts: number;
  dominantVector: DrugCategory;
}

export interface MonthlyTrend {
  month: string;
  weightKg: number;
  streetValueCr: number;
  seizureCount: number;
}

export interface SubstanceShare {
  name: DrugCategory;
  percentage: number;
  totalKg: number;
  color: string;
}

export interface AiAccuracyRow {
  category: DrugCategory;
  aiConfidence: number;
  cfslConfirmation: number;
  sampleCount: number;
}

export interface CorridorPerformance {
  name: string;
  riskLevel: "CRITICAL" | "HIGH" | "MODERATE";
  interdictionRate: number;
  monthlyVolumeKg: number;
  checkposts: number;
}

export interface DiurnalBucket {
  hour: string;
  day: number;
  night: number;
}

export interface NetworkEvent {
  id: string;
  timestamp: string;
  severity: "INFO" | "PRIORITY" | "ALERT";
  message: string;
}

export interface CheckpointStatus {
  id: string;
  name: string;
  corridor: string;
  status: "ACTIVE" | "ELEVATED" | "INTERCEPTED";
  officers: number;
  lastEvent: string;
}
