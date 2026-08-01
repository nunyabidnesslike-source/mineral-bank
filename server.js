const express = require('express');
const { Resend } = require('resend');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname)));

const resendApiKey = process.env.RESEND_API_KEY;
const resend = new Resend(resendApiKey);

// Explicit POST Route Definition
app.post('/api/contact', async (req, res) => {
    try {
        const { name, email, message } = req.body;

        if (!name || !email || !message) {
            return res.status(400).json({ success: false, error: 'Missing required fields.' });
        }

        if (!resendApiKey) {
            return res.status(500).json({ success: false, error: 'RESEND_API_KEY not found in staging environment.' });
        }

        const data = await resend.emails.send({
            from: 'Mineral Bank Staging <onboarding@resend.dev>',
            to: ['nunya.bidnesslike@gmail.com'],
            subject: "[Staging Test] Contact from " ,
            text: Name: \nEmail: \nMessage: 
        });

        return res.status(200).json({ success: true, data });
    } catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(Mineral Bank staging server running on port );
});