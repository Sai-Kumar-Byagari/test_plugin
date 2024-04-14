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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CmsClient = void 0;
const axios_1 = __importDefault(require("axios"));
const ApiPath = {
    USER_VERIFY_MPIN: '/user/verify/mpin',
    CARD_GET_BALANCE: '/card/get/balance',
    RESET_MPIN: '/card/reset/mpin',
    CARD_GET_LIST: '/card/get/list',
    CARD_GET_DETAILS: '/card/get/details',
    CARD_GET_CVV: '/card/get/cvv',
    CARD_SET_LIMIT: '/card/set/limit',
    CARD_GET_LIMIT: '/card/get/limit',
    CARD_UPGRADE_LIMIT: '/card/upgrade/limit',
    CARD_GET_PREFERENCE: '/card/get/preference',
    CARD_SET_PREFERENCE: '/card/set/preference',
    CARD_GET_STATEMENT: '/card/get/statement',
    CARD_GET_UNBILLED_TRANSACTIONS: '/card/get/unbilled/transactions',
    CARD_GET_DUE: '/card/get/due',
    CARD_UPDATE_STATEMENT_DATE: '/card/update/statement/date',
    CARD_SET_PIN: '/card/set/pin',
    CARD_GET_BILLING_DATES: '/card/get/billing_dates',
    CARD_LOCK: '/card/lock',
    CARD_UNLOCK: '/card/unlock',
    CARD_REPLACE: '/card/replace',
    CARD_GET_TRANSACTION_STATUS: '/card/get/transaction/status',
    REQUEST_PHYSICAL_CARD: '/request/physical/card',
    CARD_BLOCK: '/card/block',
    CARD_CLOSE: '/card/close',
    LOAN_ELIGIBLE_EMI_TRANSACTIONS: '/loan/eligible/emi/transactions',
    LOAN_GET_LIST: '/loan/get/list',
    LOAN_PREVIEW: '/loan/preview'
};
class CmsClient {
    constructor(options) {
        this.defaultOptions = {};
        this.options = options;
        const config = {
            baseURL: this.options.baseURL,
            headers: {
                'Content-Type': 'application/json'
            }
        };
        if (options.virtual) {
            config.headers['Virtual-Data'] = true;
        }
        this.axios = axios_1.default.create(config);
    }
    doGet(path, options) {
        return __awaiter(this, void 0, void 0, function* () {
            if (options) {
                options = Object.assign({}, this.defaultOptions, options);
            }
            try {
                const result = yield this.axios.get(path, options);
                return result.data;
            }
            catch (e) {
                console.error('Error on doGet :', {
                    path: path,
                    options: options
                }, e);
                this.handleErrorResponse(e);
            }
        });
    }
    doPost(path, payload, options) {
        return __awaiter(this, void 0, void 0, function* () {
            if (options) {
                options = Object.assign({}, this.defaultOptions, options);
            }
            try {
                const result = yield this.axios.post(path, payload, options);
                return result.data;
            }
            catch (e) {
                console.error('Error on doPost :', {
                    path: path,
                    options: options
                }, e);
                this.handleErrorResponse(e);
            }
        });
    }
    handleErrorResponse(e) {
        throw new Error();
    }
    addAuthTokenHeader(token, headers) {
        if (!headers || typeof headers !== 'object') {
            headers = {};
        }
        headers['Authorization'] = `Bearer ${token}`;
        return headers;
    }
    addActionTokenHeader(token, headers) {
        if (!headers || typeof headers !== 'object') {
            headers = {};
        }
        headers['Action-Token'] = token;
        return headers;
    }
    addOtpTokenHeader(token, headers) {
        if (!headers || typeof headers !== 'object') {
            headers = {};
        }
        headers['Otp-Token'] = token;
        return headers;
    }
    /**
     * ======================================
     *              CMS Services
     * ======================================
     */
    /**
     * Authenicate and generate a token to access cms services
     * @param id
     * @param pin
     * @returns
     */
    authenticate(id, pin) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield this.doPost(ApiPath.USER_VERIFY_MPIN, { mobileNumber: id, pin: pin });
        });
    }
    getActionToken(token, action) {
        return __awaiter(this, void 0, void 0, function* () {
            let headers = this.addAuthTokenHeader(token);
            return yield this.doPost('/', headers);
        });
    }
    getOtpToken(id) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield this.doPost('/', {});
        });
    }
    /**
     * To get the active card balance
     * @param token
     * @returns
     */
    getBalance(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.CARD_GET_BALANCE, { headers });
        });
    }
    /**
     * To get the card's list of user
     * @param token
     * @returns
     */
    getDetails(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.CARD_GET_DETAILS, { headers });
        });
    }
    /**
     * To get the card list
     * @param token
     * @param status
     * @returns
     */
    getList(token, status, type) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            if (!status && !type) {
                return yield this.doGet(ApiPath.CARD_GET_LIST, { headers });
            }
            return yield this.doPost(ApiPath.CARD_GET_LIST, { status, type }, { headers });
        });
    }
    /**
     * To get the card preferences of the user
     * @param token
     * @returns
     */
    getPreference(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.CARD_GET_PREFERENCE, { headers });
        });
    }
    /**
     * To set the card preferences of the user
     * @param payload body of user preferences
     * @returns
     */
    setPreference(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_SET_PREFERENCE, payload, { headers });
        });
    }
    /**
     * To get the limit of the card
     * @param token
     * @returns
     */
    getLimit(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.CARD_GET_LIMIT, { headers });
        });
    }
    /**
     * To upgrade the limit of the card
     * @param token
     * @param limit payload
     * @returns
     */
    upgradeLimit(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_SET_LIMIT, payload, { headers });
        });
    }
    /**
     * To get the cvv of the card
     * @param token
     * @returns
     */
    getCvv(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.CARD_GET_CVV, { headers });
        });
    }
    /**
     * To get the statement of the card
     * @param token
     * @param statement timeline specified in payload as from and to
     * @returns
     */
    getStatement(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_GET_STATEMENT, payload, { headers });
        });
    }
    /**
     * To update the statement of the card
     * @param token
     * @param statement date payload
     * @returns
     */
    updateStatementDate(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_UPDATE_STATEMENT_DATE, payload, { headers });
        });
    }
    /**
     * To get the transactions of the card
     * @param token
     * @param transaction payload
     * @returns
     */
    getTransactions(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_GET_UNBILLED_TRANSACTIONS, payload, { headers });
        });
    }
    /**
     * To request physical card approval
     * @param token
     * @param payload
     * @returns
     */
    requestPhysicalCard(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.REQUEST_PHYSICAL_CARD, payload, { headers });
        });
    }
    /**
     * To get the due amount of the card
     * @param token
     * @returns
     */
    getDue(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.CARD_GET_DUE, { headers });
        });
    }
    /**
     * To set the pin of the card
     * @param token
     * @param card pin payload
     * @returns
     */
    setPin(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_SET_PIN, payload, { headers });
        });
    }
    /**
     * To get the billing dates list eligible for the user to update
     * @param token
     * @returns
     */
    getBillingDates(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.CARD_SET_PIN, { headers });
        });
    }
    /**
     * To get the card locked
     * @param token
     * @returns
     */
    lock(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_LOCK, payload, { headers });
        });
    }
    /**
     * To get the card unlocked which is locked
     * @param token
     * @returns
     */
    unlock(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_UNLOCK, payload, { headers });
        });
    }
    /**
     * To get the card blocked for the user
     * @param token
     * @returns
     */
    block(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_BLOCK, payload, { headers });
        });
    }
    /**
     * To reset the Mpin
     * @param token
     * @param Mpin payload
     * @returns
     */
    resetMpin(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.RESET_MPIN, payload, { headers });
        });
    }
    /**
     * To get the card closed for the user
     * @param token
     * @returns
     */
    close(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_CLOSE, payload, { headers });
        });
    }
    /**
     * To get the card replaced for the user
     * @param token
     * @returns
     */
    replace(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.CARD_REPLACE, payload, { headers });
        });
    }
    /**
     * To get the EMI eligible transactions list
     * @param token
     * @returns
     */
    getEmiEligibleTransactions(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.LOAN_ELIGIBLE_EMI_TRANSACTIONS, { headers });
        });
    }
    /**
     * To get the list of EMI converted transactions
     * @param token
     * @returns
     */
    getEmiEligibleList(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doGet(ApiPath.LOAN_GET_LIST, { headers });
        });
    }
    /**
     * To get the preview of details to convert into EMI
     * @param token
     * @param payload with id and amount to convert
     * @returns
     */
    getEmiPreview(token, payload) {
        return __awaiter(this, void 0, void 0, function* () {
            const headers = this.addAuthTokenHeader(token);
            return yield this.doPost(ApiPath.LOAN_PREVIEW, payload, { headers });
        });
    }
    /**
     * To set the Cvv of the card
     * @param token
     * @returns
     */
    setCvv(token, actionToken) {
        return __awaiter(this, void 0, void 0, function* () {
            let headers = this.addAuthTokenHeader(token);
            headers = this.addActionTokenHeader(actionToken, headers);
            return yield this.doGet('/card/set/cvv', { headers });
        });
    }
}
exports.CmsClient = CmsClient;
