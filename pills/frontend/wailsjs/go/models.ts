export namespace main {
	
	export class DrugInfo {
	    id: number;
	    trade_name: string;
	    scientific_name: string;
	    size: string;
	    size_unit: string;
	    legal_status: string;
	    manufacture_name: string;
	    authorization_status: string;
	
	    static createFrom(source: any = {}) {
	        return new DrugInfo(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.trade_name = source["trade_name"];
	        this.scientific_name = source["scientific_name"];
	        this.size = source["size"];
	        this.size_unit = source["size_unit"];
	        this.legal_status = source["legal_status"];
	        this.manufacture_name = source["manufacture_name"];
	        this.authorization_status = source["authorization_status"];
	    }
	}
	export class LogEntry {
	    ScheduleId: number;
	    ScheduledAtMs: number;
	    Taken: boolean;
	    Note: string;
	
	    static createFrom(source: any = {}) {
	        return new LogEntry(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.ScheduleId = source["ScheduleId"];
	        this.ScheduledAtMs = source["ScheduledAtMs"];
	        this.Taken = source["Taken"];
	        this.Note = source["Note"];
	    }
	}
	export class Medication {
	    ID: number;
	    // Go type: time
	    CreatedAt: any;
	    // Go type: time
	    UpdatedAt: any;
	    // Go type: gorm
	    DeletedAt: any;
	    DrugInfoId: number;
	    Name: string;
	    PhotoUrl: string;
	    Type: string;
	
	    static createFrom(source: any = {}) {
	        return new Medication(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.ID = source["ID"];
	        this.CreatedAt = this.convertValues(source["CreatedAt"], null);
	        this.UpdatedAt = this.convertValues(source["UpdatedAt"], null);
	        this.DeletedAt = this.convertValues(source["DeletedAt"], null);
	        this.DrugInfoId = source["DrugInfoId"];
	        this.Name = source["Name"];
	        this.PhotoUrl = source["PhotoUrl"];
	        this.Type = source["Type"];
	    }
	
		convertValues(a: any, classs: any, asMap: boolean = false): any {
		    if (!a) {
		        return a;
		    }
		    if (a.slice && a.map) {
		        return (a as any[]).map(elem => this.convertValues(elem, classs));
		    } else if ("object" === typeof a) {
		        if (asMap) {
		            for (const key of Object.keys(a)) {
		                a[key] = new classs(a[key]);
		            }
		            return a;
		        }
		        return new classs(a);
		    }
		    return a;
		}
	}
	export class PatientScheduleView {
	    ScheduleID: number;
	    MedicationID: number;
	    Medication: string;
	    MedicationType: string;
	    // Go type: time
	    StartDate: any;
	    // Go type: time
	    EndDate: any;
	    // Go type: time
	    StartHour: any;
	    IntervalHours: number;
	    Instructions: string;
	    Dosage: string;
	    Quantity: number;
	
	    static createFrom(source: any = {}) {
	        return new PatientScheduleView(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.ScheduleID = source["ScheduleID"];
	        this.MedicationID = source["MedicationID"];
	        this.Medication = source["Medication"];
	        this.MedicationType = source["MedicationType"];
	        this.StartDate = this.convertValues(source["StartDate"], null);
	        this.EndDate = this.convertValues(source["EndDate"], null);
	        this.StartHour = this.convertValues(source["StartHour"], null);
	        this.IntervalHours = source["IntervalHours"];
	        this.Instructions = source["Instructions"];
	        this.Dosage = source["Dosage"];
	        this.Quantity = source["Quantity"];
	    }
	
		convertValues(a: any, classs: any, asMap: boolean = false): any {
		    if (!a) {
		        return a;
		    }
		    if (a.slice && a.map) {
		        return (a as any[]).map(elem => this.convertValues(elem, classs));
		    } else if ("object" === typeof a) {
		        if (asMap) {
		            for (const key of Object.keys(a)) {
		                a[key] = new classs(a[key]);
		            }
		            return a;
		        }
		        return new classs(a);
		    }
		    return a;
		}
	}
	export class User {
	    ID: number;
	    // Go type: time
	    CreatedAt: any;
	    // Go type: time
	    UpdatedAt: any;
	    // Go type: gorm
	    DeletedAt: any;
	    FirstName: string;
	    LastName: string;
	    UserName: string;
	    Email: string;
	    Password: string;
	    Gender: string;
	    Role: number;
	
	    static createFrom(source: any = {}) {
	        return new User(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.ID = source["ID"];
	        this.CreatedAt = this.convertValues(source["CreatedAt"], null);
	        this.UpdatedAt = this.convertValues(source["UpdatedAt"], null);
	        this.DeletedAt = this.convertValues(source["DeletedAt"], null);
	        this.FirstName = source["FirstName"];
	        this.LastName = source["LastName"];
	        this.UserName = source["UserName"];
	        this.Email = source["Email"];
	        this.Password = source["Password"];
	        this.Gender = source["Gender"];
	        this.Role = source["Role"];
	    }
	
		convertValues(a: any, classs: any, asMap: boolean = false): any {
		    if (!a) {
		        return a;
		    }
		    if (a.slice && a.map) {
		        return (a as any[]).map(elem => this.convertValues(elem, classs));
		    } else if ("object" === typeof a) {
		        if (asMap) {
		            for (const key of Object.keys(a)) {
		                a[key] = new classs(a[key]);
		            }
		            return a;
		        }
		        return new classs(a);
		    }
		    return a;
		}
	}

}

