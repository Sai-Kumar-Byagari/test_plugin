"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const cms_client_1 = require("./cms-client");
const cmsClient = new cms_client_1.CmsClient({
    baseURL: 'https://cmsdevapi.saven.in',
    virtual: false
});
const Cache = {
    CMS_AUTH_TOKEN: ''
};
describe("CMS-Service: Authenticate", () => {
    it("should get succes status and token", () => __awaiter(void 0, void 0, void 0, function* () {
        const result = yield cmsClient.authenticate('+919700000000', '1234');
        Cache.CMS_AUTH_TOKEN = result.data.token;
        expect(result).toBeTruthy();
        expect(result.status).toEqual("success");
    }));
});
describe("CMS-Service: GetBalance", () => {
    it("should get the active card balance", () => __awaiter(void 0, void 0, void 0, function* () {
        let mockResponse = {
            status: 'success',
            data: [
                {
                    productId: 'GENERAL',
                    balance: '985334.0',
                    lienBalance: '2392.0'
                }
            ]
        };
        const result = yield cmsClient.getBalance(Cache.CMS_AUTH_TOKEN);
        expect(result.status).toEqual("success");
        expect(result).toMatchObject(mockResponse);
    }));
});