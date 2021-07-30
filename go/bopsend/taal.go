package bopsend

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	log "github.com/ejfhp/trail"
	"github.com/ejfhp/trail/trace"
)

type MapiPayload struct {
	ApiVersion                string    `json:"apiVersion"`
	Timestamp                 time.Time `json:"timestamp"`
	ExpiryTime                time.Time `json:"expiryTime"`
	TXID                      string    `json:"txid"`
	ReturnResult              string    `json:"returnResult"`
	ResultDescription         string    `json:"resultDescription"`
	MinerID                   string    `json:"minerId"`
	CurrentHighestBlockHash   string    `json:"currentHighestBlockHash"`
	CurrentHighestBlockHeight int       `json:"currentHighestBlockHeight"`
	Fees                      Fees      `json:"fees"`
}

type MapiSubmitTX struct {
	Rawtx              string `json:"rawtx"`
	CallBackUrl        string `json:"callBackUrl"`
	CallBackToken      string `json:"callBackToken"`
	MerkleProof        bool   `json:"merkleProof"`
	MerkleFormat       string `json:"merkleFormat"`
	DsCheck            bool   `json:"dsCheck"`
	CallBackEncryption string `json:"callBackEncryption"`
}

type TAAL struct {
	BaseURL string
}

func NewTAAL() *TAAL {
	return &TAAL{BaseURL: "https://mapi.taal.com/mapi"}
}

func (l *TAAL) GetFee() (Fees, error) {
	t := trace.New().Source("taal.go", "TAAL", "GetFee")
	url := fmt.Sprintf("%s/feeQuote", l.BaseURL)
	log.Println(trace.Debug("get fee").UTC().Add("url", url).Append(t))
	resp, err := http.Get(url)
	if err != nil {
		log.Println(trace.Alert("error while getting fee").UTC().Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while getting fee: %w", err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println(trace.Alert("error while reading response").UTC().Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while reading response: %w", err)
	}
	fmt.Printf("taal body: %s\n", string(body))

	mapiResponse := make(map[string]interface{})
	err = json.Unmarshal(body, &mapiResponse)
	if err != nil {
		log.Println(trace.Alert("error while unmarshalling mapi response").UTC().Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while unmarshalling mapi response: %w", err)
	}
	payload := mapiResponse["payload"].(string)
	mapiPayload := MapiPayload{}
	err = json.Unmarshal([]byte(payload), &mapiPayload)
	if err != nil {
		log.Println(trace.Alert("error while unmarshalling mapi payload").UTC().Add("url", url).Error(err).Append(t))
		return nil, fmt.Errorf("error while unmarshalling mapi payload: %w", err)
	}
	return mapiPayload.Fees, nil
}

//SubmitTX submit the given raw tx to Tall MAPI and if succeed return TXID
func (l *TAAL) SubmitTX(rawTX string) (string, error) {
	t := trace.New().Source("taal.go", "TAAL", "SubmitTX")
	url := fmt.Sprintf("%s/tx", l.BaseURL)
	log.Println(trace.Debug("submit tx").UTC().Add("url", url).Append(t))
	mapiSubmitTX := MapiSubmitTX{
		Rawtx:       rawTX,
		MerkleProof: false,
		DsCheck:     false,
	}
	payload, err := json.Marshal(mapiSubmitTX)
	if err != nil {
		log.Println(trace.Alert("error while marshalling MapiSubmitTX").UTC().Add("url", url).Error(err).Append(t))
		return "", fmt.Errorf("error while marshalling MapiSubmitTX: %w", err)
	}
	resp, err := http.Post(url, "application/json", bytes.NewReader(payload))
	if err != nil {
		log.Println(trace.Alert("error while posting TX").UTC().Add("url", url).Error(err).Append(t))
		return "", fmt.Errorf("error while posting TX: %w", err)
	}
	body, _ := ioutil.ReadAll(resp.Body)
	log.Println(trace.Info("miner response").UTC().Add("url", url).Add("response", string(body)).Append(t))
	if resp.StatusCode != 200 {
		log.Println(trace.Alert("miner replied bit bad status").UTC().Add("url", url).Add("status", resp.Status).Append(t))
		return "", fmt.Errorf("miner replied bit bad status: %s", resp.Status)

	}
	mapiResponse := make(map[string]interface{})
	err = json.Unmarshal(body, &mapiResponse)
	if err != nil {
		log.Println(trace.Alert("error while unmarshalling mapi response").UTC().Add("url", url).Error(err).Append(t))
		return "", fmt.Errorf("error while unmarshalling mapi response: %w", err)
	}
	responsePayload := mapiResponse["payload"].(string)
	mapiPayload := MapiPayload{}
	err = json.Unmarshal([]byte(responsePayload), &mapiPayload)
	if err != nil {
		log.Println(trace.Alert("error while unmarshalling mapi payload").UTC().Add("url", url).Error(err).Append(t))
		return "", fmt.Errorf("error while unmarshalling mapi payload: %w", err)
	}
	if mapiPayload.ReturnResult != "success" {
		log.Println(trace.Alert("mapi call unsuccesful").UTC().Add("return", mapiPayload.ReturnResult).Add("returnDecription", mapiPayload.ResultDescription).Append(t))
		return "", fmt.Errorf("mapi call unsuccesfull: %s, %s", mapiPayload.ReturnResult, mapiPayload.ResultDescription)

	}
	txid := mapiPayload.TXID
	return txid, nil
}
