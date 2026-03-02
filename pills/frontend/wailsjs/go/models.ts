export namespace main {
	
	export class UserDTO {
	    id: number;
	    firstName: string;
	    lastName: string;
	    userName: string;
	    email: string;
	    password: string;
	    gender: string;
	    role: number;
	
	    static createFrom(source: any = {}) {
	        return new UserDTO(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.firstName = source["firstName"];
	        this.lastName = source["lastName"];
	        this.userName = source["userName"];
	        this.email = source["email"];
	        this.password = source["password"];
	        this.gender = source["gender"];
	        this.role = source["role"];
	    }
	}

}

