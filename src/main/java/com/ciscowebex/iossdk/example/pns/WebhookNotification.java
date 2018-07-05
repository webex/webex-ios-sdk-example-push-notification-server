// Copyright 2016-2017 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package com.ciscowebex.iossdk.example.pns;

public class WebhookNotification {

	private String id;

	private String name;

	private String resource;

	private String event;

	private String filter;

	private String orgId;

	private String appId;

	private String createdBy;

	private String ownedBy;

	private String status;

	private String actorId;

	private Data data;

	public WebhookNotification() {

	}

	public String getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public String getResource() {
		return resource;
	}

	public String getActorId() {
		return actorId;
	}

	public String getEvent() {
		return event;
	}

	public String getFilter() {
		return filter;
	}

	public String getOrgId() {
		return orgId;
	}

	public String getAppId() {
		return appId;
	}

	public String getOwnedBy() {
		return ownedBy;
	}

	public String getStatus() {
		return status;
	}

	public String getCreatedBy() {
		return createdBy;
	}

	public Data getData() {
		return data;
	}

	public class Data {

		private String id;
		
		private String callId;
		
		private String personId;
		
		private String personEmail;
		
		private String state;

		public String getId() {
			return id;
		}

		public String getState() {
			return state;
		}

		public String getCreated() {
			return created;
		}

		private String created;

		public String getCallId() {
			return callId;
		}

		public String getPersonId() {
			return personId;
		}

		public String getPersonEmail() {
			return personEmail;
		}
	}
}

